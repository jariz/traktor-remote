import Foundation
import Core

@_cdecl("traktorRemoteInit")
public func traktorRemoteInit() {
    switch enableRobotServer(task: mach_task_self_) {
    case .success(let address):
        NSLog("[TraktorRemote] Patched at 0x%llx - RPC server enabled on port 8080", address)
    case .patternNotFound:
        NSLog("[TraktorRemote] Pattern not found")
    case .patchFailed(let address):
        NSLog("[TraktorRemote] Patch failed at 0x%llx", address)
    }
}
