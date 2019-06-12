function dartMainRunner(main, args) {
  self.Udp = require('./lib/udp/udp');
  main(args);
}
