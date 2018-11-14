
var Helper = function () {
  // do nothing
};

Helper.isNumber = function (n) { 
  return !isNaN(parseFloat(n)) && isFinite(n);
}

module.exports = Helper;