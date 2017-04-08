import Foundation

/*
  Encapsulates access to the weights that are stored in parameters.data.
  
  We only need to read from the parameters file while the neural network is
  being created. The weights are copied into the network (as 16-bit floats),
  so once the network is set up we no longer need to keep parameters.data
  in memory.

  Because this is a huge file, we use mmap() so that not the entire file has
  to be read into memory at once. Deallocating VGGNetData unmaps the file.
*/
class VGGNetData {
  // Size of the data file in bytes.
  let fileSize = 58858752

  // These are the offsets in the big blob of data of the weights and biases
  // for each layer. (This code was generated by the convert_vggnet.py script.)

  var conv1_1_w: UnsafeMutablePointer<Float> { return ptr + 0 }
  var conv1_1_b: UnsafeMutablePointer<Float> { return ptr + 1728 }
  var conv1_2_w: UnsafeMutablePointer<Float> { return ptr + 1792 }
  var conv1_2_b: UnsafeMutablePointer<Float> { return ptr + 38656 }
  var conv2_1_w: UnsafeMutablePointer<Float> { return ptr + 38720 }
  var conv2_1_b: UnsafeMutablePointer<Float> { return ptr + 112448 }
  var conv2_2_w: UnsafeMutablePointer<Float> { return ptr + 112576 }
  var conv2_2_b: UnsafeMutablePointer<Float> { return ptr + 260032 }
  var conv3_1_w: UnsafeMutablePointer<Float> { return ptr + 260160 }
  var conv3_1_b: UnsafeMutablePointer<Float> { return ptr + 555072 }
  var conv3_2_w: UnsafeMutablePointer<Float> { return ptr + 555328 }
  var conv3_2_b: UnsafeMutablePointer<Float> { return ptr + 1145152 }
  var conv3_3_w: UnsafeMutablePointer<Float> { return ptr + 1145408 }
  var conv3_3_b: UnsafeMutablePointer<Float> { return ptr + 1735232 }
  var conv4_1_w: UnsafeMutablePointer<Float> { return ptr + 1735488 }
  var conv4_1_b: UnsafeMutablePointer<Float> { return ptr + 2915136 }
  var conv4_2_w: UnsafeMutablePointer<Float> { return ptr + 2915648 }
  var conv4_2_b: UnsafeMutablePointer<Float> { return ptr + 5274944 }
  var conv4_3_w: UnsafeMutablePointer<Float> { return ptr + 5275456 }
  var conv4_3_b: UnsafeMutablePointer<Float> { return ptr + 7634752 }
  var conv5_1_w: UnsafeMutablePointer<Float> { return ptr + 7635264 }
  var conv5_1_b: UnsafeMutablePointer<Float> { return ptr + 9994560 }
  var conv5_2_w: UnsafeMutablePointer<Float> { return ptr + 9995072 }
  var conv5_2_b: UnsafeMutablePointer<Float> { return ptr + 12354368 }
  var conv5_3_w: UnsafeMutablePointer<Float> { return ptr + 12354880 }
  var conv5_3_b: UnsafeMutablePointer<Float> { return ptr + 14714176 }
//  var fc6_w: UnsafeMutablePointer<Float> { return ptr + 14714688 }
//  var fc6_b: UnsafeMutablePointer<Float> { return ptr + 117475136 }
//  var fc7_w: UnsafeMutablePointer<Float> { return ptr + 117479232 }
//  var fc7_b: UnsafeMutablePointer<Float> { return ptr + 134256448 }
//  var fc8_w: UnsafeMutablePointer<Float> { return ptr + 134260544 }
//  var fc8_b: UnsafeMutablePointer<Float> { return ptr + 138356544 }

  private var fd: CInt!
  private var hdr: UnsafeMutableRawPointer!
  private var ptr: UnsafeMutablePointer<Float>!

  /* This is for debugging. Initializing the weights to 0 gives an output of
     0.000999451, or approx 1/1000 for all classes, which is what you'd expect
     for a softmax classifier. */
  init() {
    let numBytes = fileSize / MemoryLayout<Float>.size
    ptr = UnsafeMutablePointer<Float>.allocate(capacity: numBytes)
    ptr.initialize(to: 0, count: numBytes)
  }

  init?(path: String) {
    fd = open(path, O_RDONLY, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH)
    if fd == -1 {
      print("Error: failed to open \"\(path)\", error = \(errno)")
      return nil
    }

    hdr = mmap(nil, fileSize, PROT_READ, MAP_FILE | MAP_SHARED, fd, 0)
    if hdr == nil {
      print("Error: mmap failed, errno = \(errno)")
      return nil
    }

    let numBytes = fileSize / MemoryLayout<Float>.size
    ptr = hdr.bindMemory(to: Float.self, capacity: numBytes)
    if ptr == UnsafeMutablePointer<Float>(bitPattern: -1) {
      print("Error: mmap failed, errno = \(errno)")
      return nil
    }
  }

  deinit{
    print("deinit \(self)")

    if let hdr = hdr {
      let result = munmap(hdr, Int(fileSize))
      assert(result == 0, "Error: munmap failed, errno = \(errno)")
    }
    if let fd = fd {
      close(fd)
    }
  }
}
