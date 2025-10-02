// pragma Singleton

// import QtQuick
// import Quickshell
// import Quickshell.Io
// import qs.Commons
// import qs.Services

// Singleton {
//   id: root

//   property real bpm: 1.0

//   Process {
//     running: false//true
//     command: ["/usr/local/bin/beat_detector", "--no-log", "--no-stats", "--no-visual"]
//     stdout: SplitParser {
//       onRead: data => {
//         const match = data.match(/BPM: ([0-9]+\.[0-9])/);
//         if (match) {
//             // Logger.log("BPM: ", parseFloat(match[1]))
//             root.bpm = parseFloat(match[1]);
//         }
//       }
//     }
//   }
// }
