import Foundation
import Darwin
import Core

func findTraktorExecutable() -> String? {
    let fm = FileManager.default
    let applicationsURL = URL(fileURLWithPath: "/Applications")

    guard let enumerator = fm.enumerator(
        at: applicationsURL,
        includingPropertiesForKeys: [.isDirectoryKey],
        options: [.skipsHiddenFiles]
    ) else { return nil }

    for case let url as URL in enumerator {
        if url.lastPathComponent.hasPrefix("Traktor") && url.pathExtension == "app" {
            let executable = url.appendingPathComponent("Contents/MacOS/\(url.deletingPathExtension().lastPathComponent)")
            if fm.isExecutableFile(atPath: executable.path) {
                return executable.path
            }
        }
    }
    return nil
}

func getTaskPort(pid: pid_t) -> mach_port_t? {
    var task: mach_port_t = 0
    let result = task_for_pid(mach_task_self_, pid, &task)
    if result != KERN_SUCCESS {
        print("[-] task_for_pid failed: \(result)")
        return nil
    }
    return task
}

// MARK: - Main

print("""
    ╔══════════════════════════════════╗
    ║   Traktor Remote Control - CLI   ║
    ╚══════════════════════════════════╝
    """)

print("\n[*] Searching for Traktor...")
guard let traktorPath = findTraktorExecutable() else {
    print("[-] Traktor not found in /Applications/")
    exit(1)
}
print("[+] Found: \(traktorPath)")

print("[*] Launching Traktor...")
let process = Process()
process.executableURL = URL(fileURLWithPath: traktorPath)

do {
    try process.run()
} catch {
    print("[-] Failed to launch: \(error)")
    exit(1)
}

let pid = process.processIdentifier
print("[+] PID: \(pid)")

print("[*] Suspending process...")
kill(pid, SIGSTOP)
Thread.sleep(forTimeInterval: 0.1)

print("[*] Getting task port...")
guard let task = getTaskPort(pid: pid) else {
    print("[-] Failed to get task port")
    process.waitUntilExit()
    exit(1)
}
print("[+] Task port: \(task)")

print("[*] Enumerating memory regions...")
let regions = getMemoryRegions(task: task)
let executableRegions = regions.filter { ($0.protection & VM_PROT_EXECUTE) != 0 }
print("[+] Found \(regions.count) regions (\(executableRegions.count) executable)")

print("[*] Scanning for feature_is_on pattern...")

switch enableRobotServer(task: task) {
case .success(let address):
    print("[+] Found feature_is_on at: 0x\(String(address, radix: 16))")
    print("[+] Patch successful!")
case .patternNotFound:
    print("[-] Pattern not found!")
    print("    The binary might have changed or pattern needs updating")
    mach_port_deallocate(mach_task_self_, task)
    process.waitUntilExit()
    exit(1)
case .patchFailed(let address):
    print("[+] Found feature_is_on at: 0x\(String(address, radix: 16))")
    print("[-] Patch failed!")
}

mach_port_deallocate(mach_task_self_, task)

print("[*] Resuming process...")
kill(pid, SIGCONT)
print("[+] Robot server should be enabled on port 8080")

print("\n[*] Traktor is running. Press Ctrl+C to quit.\n")
process.waitUntilExit()
print("[*] Traktor exited with code: \(process.terminationStatus)")
