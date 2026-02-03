import Foundation
import Darwin

// MARK: - Pattern Definition

public let searchPattern: [UInt8?] = [
    nil, nil, nil, 0x14,        // b <offset> - feature_is_on
    0xfd, 0x7b, 0xbf, 0xa9,     // stp x29, x30, [sp, #-0x10]!
    0xfd, 0x03, 0x00, 0x91,     // mov x29, sp
    nil, nil, nil, 0x94,        // bl <offset>
    nil, nil, nil, nil,         // (varies - xor or mov)
    0xfd, 0x7b, 0xc1, 0xa8,     // ldp x29, x30, [sp], #0x10
    0xc0, 0x03, 0x5f, 0xd6      // ret
]

public let patchBytes: [UInt8] = [
    0x20, 0x00, 0x80, 0x52,  // MOV W0, #1
    0xC0, 0x03, 0x5F, 0xD6   // RET
]

// MARK: - Memory Region

public struct MemoryRegion {
    public let address: mach_vm_address_t
    public let size: mach_vm_size_t
    public let protection: vm_prot_t
}

// MARK: - Memory Operations

public func getMemoryRegions(task: mach_port_t) -> [MemoryRegion] {
    var regions: [MemoryRegion] = []
    var address: mach_vm_address_t = 0

    while true {
        var size: mach_vm_size_t = 0
        var info = vm_region_basic_info_data_64_t()
        var infoCount = mach_msg_type_number_t(MemoryLayout<vm_region_basic_info_data_64_t>.size / MemoryLayout<Int32>.size)
        var objectName: mach_port_t = 0

        let result = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: Int32.self, capacity: Int(infoCount)) { intPtr in
                mach_vm_region(task, &address, &size, VM_REGION_BASIC_INFO_64, intPtr, &infoCount, &objectName)
            }
        }

        if result != KERN_SUCCESS { break }

        if (info.protection & VM_PROT_READ) != 0 {
            regions.append(MemoryRegion(address: address, size: size, protection: info.protection))
        }
        address += size
    }
    return regions
}

public func readMemory(task: mach_port_t, address: mach_vm_address_t, size: mach_vm_size_t) -> Data? {
    var data = Data(count: Int(size))
    var outSize: mach_vm_size_t = 0

    let result = data.withUnsafeMutableBytes { ptr in
        mach_vm_read_overwrite(task, address, size, unsafeBitCast(ptr.baseAddress, to: mach_vm_address_t.self), &outSize)
    }
    return result == KERN_SUCCESS ? data : nil
}

public func findPattern(_ pattern: [UInt8?], in data: Data) -> Int? {
    let patternLength = pattern.count
    guard data.count >= patternLength else { return nil }

    for i in 0...(data.count - patternLength) {
        var matched = true
        for j in 0..<patternLength {
            if let expected = pattern[j], data[i + j] != expected {
                matched = false
                break
            }
        }
        if matched { return i }
    }
    return nil
}

public func scanMemoryForPattern(task: mach_port_t, pattern: [UInt8?], regions: [MemoryRegion]) -> mach_vm_address_t? {
    for region in regions {
        guard (region.protection & VM_PROT_EXECUTE) != 0 else { continue }
        guard let data = readMemory(task: task, address: region.address, size: region.size) else { continue }
        if let offset = findPattern(pattern, in: data) {
            return region.address + mach_vm_address_t(offset)
        }
    }
    return nil
}

public func patchMemory(task: mach_port_t, address: mach_vm_address_t, bytes: [UInt8]) -> Bool {
    let size = mach_vm_size_t(bytes.count)

    var result = mach_vm_protect(task, address, size, 0, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY)
    if result != KERN_SUCCESS { return false }

    result = bytes.withUnsafeBytes { ptr in
        mach_vm_write(task, address, vm_offset_t(bitPattern: ptr.baseAddress), mach_msg_type_number_t(bytes.count))
    }
    if result != KERN_SUCCESS { return false }

    mach_vm_protect(task, address, size, 0, VM_PROT_READ | VM_PROT_EXECUTE)
    return true
}

// MARK: - High-level API

public enum PatchResult {
    case success(address: mach_vm_address_t)
    case patternNotFound
    case patchFailed(address: mach_vm_address_t)
}

public func enableRobotServer(task: mach_port_t) -> PatchResult {
    let regions = getMemoryRegions(task: task)

    guard let address = scanMemoryForPattern(task: task, pattern: searchPattern, regions: regions) else {
        return .patternNotFound
    }

    if patchMemory(task: task, address: address, bytes: patchBytes) {
        return .success(address: address)
    } else {
        return .patchFailed(address: address)
    }
}
