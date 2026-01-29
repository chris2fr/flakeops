// Compiles a dart2wasm-generated main module from `source` which can then
// instantiatable via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm modules from `bytes` which is then
// instantiatable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export async function instantiate(modulePromise, importObjectPromise) {
  var moduleOrCompiledApp = await modulePromise;
  if (!(moduleOrCompiledApp instanceof CompiledApp)) {
    moduleOrCompiledApp = new CompiledApp(moduleOrCompiledApp);
  }
  const instantiatedApp = await moduleOrCompiledApp.instantiate(await importObjectPromise);
  return instantiatedApp.instantiatedModule;
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export const invoke = (moduleInstance, ...args) => {
  moduleInstance.exports.$invokeMain(args);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredWasm` is a JS function that takes a module name matching a
  //   wasm file produced by the dart2wasm compiler and returns the bytes to
  //   load the module. These bytes can be in either a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  // `loadDynamicModule` is a JS function that takes two string names matching,
  //   in order, a wasm file produced by the dart2wasm compiler during dynamic
  //   module compilation and a corresponding js file produced by the same
  //   compilation. It should return a JS Array containing 2 elements. The first
  //   should be the bytes for the wasm module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The second
  //   should be the result of using the JS 'import' API on the js file path.
  async instantiate(additionalImports, {loadDeferredWasm, loadDynamicModule} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            _3: (o, t) => typeof o === t,
      _4: (o, c) => o instanceof c,
      _5: o => Object.keys(o),
      _8: (o, a) => o + a,
      _18: (o, a) => o == a,
      _35: () => new Array(),
      _36: x0 => new Array(x0),
      _38: x0 => x0.length,
      _40: (x0,x1) => x0[x1],
      _41: (x0,x1,x2) => { x0[x1] = x2 },
      _43: x0 => new Promise(x0),
      _45: (x0,x1,x2) => new DataView(x0,x1,x2),
      _47: x0 => new Int8Array(x0),
      _48: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      _49: x0 => new Uint8Array(x0),
      _51: x0 => new Uint8ClampedArray(x0),
      _53: x0 => new Int16Array(x0),
      _55: x0 => new Uint16Array(x0),
      _57: x0 => new Int32Array(x0),
      _59: x0 => new Uint32Array(x0),
      _61: x0 => new Float32Array(x0),
      _63: x0 => new Float64Array(x0),
      _65: (x0,x1,x2) => x0.call(x1,x2),
      _67: (x0,x1) => x0.call(x1),
      _70: (decoder, codeUnits) => decoder.decode(codeUnits),
      _71: () => new TextDecoder("utf-8", {fatal: true}),
      _72: () => new TextDecoder("utf-8", {fatal: false}),
      _73: (s) => +s,
      _74: x0 => new Uint8Array(x0),
      _75: (x0,x1,x2) => x0.set(x1,x2),
      _76: (x0,x1) => x0.transferFromImageBitmap(x1),
      _78: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._78(f,arguments.length,x0) }),
      _79: x0 => new window.FinalizationRegistry(x0),
      _80: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      _81: (x0,x1) => x0.unregister(x1),
      _82: (x0,x1,x2) => x0.slice(x1,x2),
      _83: (x0,x1) => x0.decode(x1),
      _84: (x0,x1) => x0.segment(x1),
      _85: () => new TextDecoder(),
      _86: (x0,x1) => x0.get(x1),
      _87: x0 => x0.buffer,
      _88: x0 => x0.wasmMemory,
      _89: () => globalThis.window._flutter_skwasmInstance,
      _90: x0 => x0.rasterStartMilliseconds,
      _91: x0 => x0.rasterEndMilliseconds,
      _92: x0 => x0.imageBitmaps,
      _196: x0 => x0.stopPropagation(),
      _197: x0 => x0.preventDefault(),
      _199: x0 => x0.remove(),
      _200: (x0,x1) => x0.append(x1),
      _201: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _246: x0 => x0.unlock(),
      _247: x0 => x0.getReader(),
      _248: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _249: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _250: (x0,x1) => x0.item(x1),
      _251: x0 => x0.next(),
      _252: x0 => x0.now(),
      _253: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._253(f,arguments.length,x0) }),
      _254: (x0,x1) => x0.addListener(x1),
      _255: (x0,x1) => x0.removeListener(x1),
      _256: (x0,x1) => x0.matchMedia(x1),
      _257: (x0,x1) => x0.revokeObjectURL(x1),
      _258: x0 => x0.close(),
      _259: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      _260: x0 => new window.ImageDecoder(x0),
      _261: x0 => ({frameIndex: x0}),
      _262: (x0,x1) => x0.decode(x1),
      _263: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._263(f,arguments.length,x0) }),
      _264: (x0,x1) => x0.getModifierState(x1),
      _265: (x0,x1) => x0.removeProperty(x1),
      _266: (x0,x1) => x0.prepend(x1),
      _267: x0 => new Intl.Locale(x0),
      _268: x0 => x0.disconnect(),
      _269: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._269(f,arguments.length,x0) }),
      _270: (x0,x1) => x0.getAttribute(x1),
      _271: (x0,x1) => x0.contains(x1),
      _272: (x0,x1) => x0.querySelector(x1),
      _273: x0 => x0.blur(),
      _274: x0 => x0.hasFocus(),
      _275: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _276: (x0,x1) => x0.hasAttribute(x1),
      _277: (x0,x1) => x0.getModifierState(x1),
      _278: (x0,x1) => x0.createTextNode(x1),
      _279: (x0,x1) => x0.appendChild(x1),
      _280: (x0,x1) => x0.removeAttribute(x1),
      _281: x0 => x0.getBoundingClientRect(),
      _282: (x0,x1) => x0.observe(x1),
      _283: x0 => x0.disconnect(),
      _284: (x0,x1) => x0.closest(x1),
      _707: () => globalThis.window.flutterConfiguration,
      _709: x0 => x0.assetBase,
      _714: x0 => x0.canvasKitMaximumSurfaces,
      _715: x0 => x0.debugShowSemanticsNodes,
      _716: x0 => x0.hostElement,
      _717: x0 => x0.multiViewEnabled,
      _718: x0 => x0.nonce,
      _720: x0 => x0.fontFallbackBaseUrl,
      _730: x0 => x0.console,
      _731: x0 => x0.devicePixelRatio,
      _732: x0 => x0.document,
      _733: x0 => x0.history,
      _734: x0 => x0.innerHeight,
      _735: x0 => x0.innerWidth,
      _736: x0 => x0.location,
      _737: x0 => x0.navigator,
      _738: x0 => x0.visualViewport,
      _739: x0 => x0.performance,
      _741: x0 => x0.URL,
      _743: (x0,x1) => x0.getComputedStyle(x1),
      _744: x0 => x0.screen,
      _745: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._745(f,arguments.length,x0) }),
      _746: (x0,x1) => x0.requestAnimationFrame(x1),
      _751: (x0,x1) => x0.warn(x1),
      _753: (x0,x1) => x0.debug(x1),
      _754: x0 => globalThis.parseFloat(x0),
      _755: () => globalThis.window,
      _756: () => globalThis.Intl,
      _757: () => globalThis.Symbol,
      _758: (x0,x1,x2,x3,x4) => globalThis.createImageBitmap(x0,x1,x2,x3,x4),
      _760: x0 => x0.clipboard,
      _761: x0 => x0.maxTouchPoints,
      _762: x0 => x0.vendor,
      _763: x0 => x0.language,
      _764: x0 => x0.platform,
      _765: x0 => x0.userAgent,
      _766: (x0,x1) => x0.vibrate(x1),
      _767: x0 => x0.languages,
      _768: x0 => x0.documentElement,
      _769: (x0,x1) => x0.querySelector(x1),
      _772: (x0,x1) => x0.createElement(x1),
      _775: (x0,x1) => x0.createEvent(x1),
      _776: x0 => x0.activeElement,
      _779: x0 => x0.head,
      _780: x0 => x0.body,
      _782: (x0,x1) => { x0.title = x1 },
      _785: x0 => x0.visibilityState,
      _786: () => globalThis.document,
      _787: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._787(f,arguments.length,x0) }),
      _788: (x0,x1) => x0.dispatchEvent(x1),
      _796: x0 => x0.target,
      _798: x0 => x0.timeStamp,
      _799: x0 => x0.type,
      _801: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      _807: x0 => x0.baseURI,
      _808: x0 => x0.firstChild,
      _812: x0 => x0.parentElement,
      _814: (x0,x1) => { x0.textContent = x1 },
      _815: x0 => x0.parentNode,
      _816: x0 => x0.nextSibling,
      _817: (x0,x1) => x0.removeChild(x1),
      _818: x0 => x0.isConnected,
      _823: x0 => x0.firstElementChild,
      _826: x0 => x0.clientHeight,
      _827: x0 => x0.clientWidth,
      _828: x0 => x0.offsetHeight,
      _829: x0 => x0.offsetWidth,
      _830: x0 => x0.id,
      _831: (x0,x1) => { x0.id = x1 },
      _834: (x0,x1) => { x0.spellcheck = x1 },
      _835: x0 => x0.tagName,
      _836: x0 => x0.style,
      _838: (x0,x1) => x0.querySelectorAll(x1),
      _839: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _840: (x0,x1) => { x0.tabIndex = x1 },
      _841: x0 => x0.tabIndex,
      _842: (x0,x1) => x0.focus(x1),
      _843: x0 => x0.scrollTop,
      _844: (x0,x1) => { x0.scrollTop = x1 },
      _845: x0 => x0.scrollLeft,
      _846: (x0,x1) => { x0.scrollLeft = x1 },
      _847: x0 => x0.classList,
      _849: (x0,x1) => { x0.className = x1 },
      _851: (x0,x1) => x0.getElementsByClassName(x1),
      _852: x0 => x0.click(),
      _853: (x0,x1) => x0.attachShadow(x1),
      _856: x0 => x0.computedStyleMap(),
      _857: (x0,x1) => x0.get(x1),
      _863: (x0,x1) => x0.getPropertyValue(x1),
      _864: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      _865: x0 => x0.offsetLeft,
      _866: x0 => x0.offsetTop,
      _867: x0 => x0.offsetParent,
      _869: (x0,x1) => { x0.name = x1 },
      _870: x0 => x0.content,
      _871: (x0,x1) => { x0.content = x1 },
      _875: (x0,x1) => { x0.src = x1 },
      _876: x0 => x0.naturalWidth,
      _877: x0 => x0.naturalHeight,
      _881: (x0,x1) => { x0.crossOrigin = x1 },
      _883: (x0,x1) => { x0.decoding = x1 },
      _884: x0 => x0.decode(),
      _889: (x0,x1) => { x0.nonce = x1 },
      _894: (x0,x1) => { x0.width = x1 },
      _896: (x0,x1) => { x0.height = x1 },
      _899: (x0,x1) => x0.getContext(x1),
      _960: x0 => x0.width,
      _961: x0 => x0.height,
      _963: (x0,x1) => x0.fetch(x1),
      _964: x0 => x0.status,
      _965: x0 => x0.headers,
      _966: x0 => x0.body,
      _967: x0 => x0.arrayBuffer(),
      _970: x0 => x0.read(),
      _971: x0 => x0.value,
      _972: x0 => x0.done,
      _979: x0 => x0.name,
      _980: x0 => x0.x,
      _981: x0 => x0.y,
      _984: x0 => x0.top,
      _985: x0 => x0.right,
      _986: x0 => x0.bottom,
      _987: x0 => x0.left,
      _997: x0 => x0.height,
      _998: x0 => x0.width,
      _999: x0 => x0.scale,
      _1000: (x0,x1) => { x0.value = x1 },
      _1003: (x0,x1) => { x0.placeholder = x1 },
      _1005: (x0,x1) => { x0.name = x1 },
      _1006: x0 => x0.selectionDirection,
      _1007: x0 => x0.selectionStart,
      _1008: x0 => x0.selectionEnd,
      _1011: x0 => x0.value,
      _1013: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1014: x0 => x0.readText(),
      _1015: (x0,x1) => x0.writeText(x1),
      _1017: x0 => x0.altKey,
      _1018: x0 => x0.code,
      _1019: x0 => x0.ctrlKey,
      _1020: x0 => x0.key,
      _1021: x0 => x0.keyCode,
      _1022: x0 => x0.location,
      _1023: x0 => x0.metaKey,
      _1024: x0 => x0.repeat,
      _1025: x0 => x0.shiftKey,
      _1026: x0 => x0.isComposing,
      _1028: x0 => x0.state,
      _1029: (x0,x1) => x0.go(x1),
      _1031: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      _1032: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _1033: x0 => x0.pathname,
      _1034: x0 => x0.search,
      _1035: x0 => x0.hash,
      _1039: x0 => x0.state,
      _1042: (x0,x1) => x0.createObjectURL(x1),
      _1044: x0 => new Blob(x0),
      _1046: x0 => new MutationObserver(x0),
      _1047: (x0,x1,x2) => x0.observe(x1,x2),
      _1048: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1048(f,arguments.length,x0,x1) }),
      _1051: x0 => x0.attributeName,
      _1052: x0 => x0.type,
      _1053: x0 => x0.matches,
      _1054: x0 => x0.matches,
      _1058: x0 => x0.relatedTarget,
      _1060: x0 => x0.clientX,
      _1061: x0 => x0.clientY,
      _1062: x0 => x0.offsetX,
      _1063: x0 => x0.offsetY,
      _1066: x0 => x0.button,
      _1067: x0 => x0.buttons,
      _1068: x0 => x0.ctrlKey,
      _1072: x0 => x0.pointerId,
      _1073: x0 => x0.pointerType,
      _1074: x0 => x0.pressure,
      _1075: x0 => x0.tiltX,
      _1076: x0 => x0.tiltY,
      _1077: x0 => x0.getCoalescedEvents(),
      _1080: x0 => x0.deltaX,
      _1081: x0 => x0.deltaY,
      _1082: x0 => x0.wheelDeltaX,
      _1083: x0 => x0.wheelDeltaY,
      _1084: x0 => x0.deltaMode,
      _1091: x0 => x0.changedTouches,
      _1094: x0 => x0.clientX,
      _1095: x0 => x0.clientY,
      _1098: x0 => x0.data,
      _1101: (x0,x1) => { x0.disabled = x1 },
      _1103: (x0,x1) => { x0.type = x1 },
      _1104: (x0,x1) => { x0.max = x1 },
      _1105: (x0,x1) => { x0.min = x1 },
      _1106: x0 => x0.value,
      _1107: (x0,x1) => { x0.value = x1 },
      _1108: x0 => x0.disabled,
      _1109: (x0,x1) => { x0.disabled = x1 },
      _1111: (x0,x1) => { x0.placeholder = x1 },
      _1112: (x0,x1) => { x0.name = x1 },
      _1115: (x0,x1) => { x0.autocomplete = x1 },
      _1116: x0 => x0.selectionDirection,
      _1117: x0 => x0.selectionStart,
      _1119: x0 => x0.selectionEnd,
      _1122: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1123: (x0,x1) => x0.add(x1),
      _1126: (x0,x1) => { x0.noValidate = x1 },
      _1127: (x0,x1) => { x0.method = x1 },
      _1128: (x0,x1) => { x0.action = x1 },
      _1154: x0 => x0.orientation,
      _1155: x0 => x0.width,
      _1156: x0 => x0.height,
      _1157: (x0,x1) => x0.lock(x1),
      _1176: x0 => new ResizeObserver(x0),
      _1179: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1179(f,arguments.length,x0,x1) }),
      _1187: x0 => x0.length,
      _1188: x0 => x0.iterator,
      _1189: x0 => x0.Segmenter,
      _1190: x0 => x0.v8BreakIterator,
      _1191: (x0,x1) => new Intl.Segmenter(x0,x1),
      _1194: x0 => x0.language,
      _1195: x0 => x0.script,
      _1196: x0 => x0.region,
      _1214: x0 => x0.done,
      _1215: x0 => x0.value,
      _1216: x0 => x0.index,
      _1220: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      _1221: (x0,x1) => x0.adoptText(x1),
      _1222: x0 => x0.first(),
      _1223: x0 => x0.next(),
      _1224: x0 => x0.current(),
      _1238: x0 => x0.hostElement,
      _1239: x0 => x0.viewConstraints,
      _1242: x0 => x0.maxHeight,
      _1243: x0 => x0.maxWidth,
      _1244: x0 => x0.minHeight,
      _1245: x0 => x0.minWidth,
      _1246: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1246(f,arguments.length,x0) }),
      _1247: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1247(f,arguments.length,x0) }),
      _1248: (x0,x1) => ({addView: x0,removeView: x1}),
      _1251: x0 => x0.loader,
      _1252: () => globalThis._flutter,
      _1253: (x0,x1) => x0.didCreateEngineInitializer(x1),
      _1254: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1254(f,arguments.length,x0) }),
      _1255: f => finalizeWrapper(f, function() { return dartInstance.exports._1255(f,arguments.length) }),
      _1256: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      _1259: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1259(f,arguments.length,x0) }),
      _1260: x0 => ({runApp: x0}),
      _1262: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1262(f,arguments.length,x0,x1) }),
      _1263: x0 => x0.length,
      _1264: () => globalThis.window.ImageDecoder,
      _1265: x0 => x0.tracks,
      _1267: x0 => x0.completed,
      _1269: x0 => x0.image,
      _1275: x0 => x0.displayWidth,
      _1276: x0 => x0.displayHeight,
      _1277: x0 => x0.duration,
      _1280: x0 => x0.ready,
      _1281: x0 => x0.selectedTrack,
      _1282: x0 => x0.repetitionCount,
      _1283: x0 => x0.frameCount,
      _1326: () => globalThis.isPrimary(),
      _1327: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1327(f,arguments.length,x0) }),
      _1328: (x0,x1) => x0.postMessage(x1),
      _1329: x0 => globalThis.setPrimary(x0),
      _1330: x0 => new BroadcastChannel(x0),
      _1343: x0 => x0.preventDefault(),
      _1344: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1344(f,arguments.length,x0) }),
      _1345: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1346: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _1347: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1347(f,arguments.length,x0) }),
      _1348: (x0,x1) => ({type: x0,callback: x1}),
      _1349: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1349(f,arguments.length,x0) }),
      _1350: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1350(f,arguments.length,x0) }),
      _1351: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1351(f,arguments.length,x0) }),
      _1352: x0 => x0.type,
      _1353: x0 => x0.callback,
      _1355: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1355(f,arguments.length,x0) }),
      _1356: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1356(f,arguments.length,x0) }),
      _1357: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1357(f,arguments.length,x0) }),
      _1358: (x0,x1) => x0.getType(x1),
      _1359: x0 => x0.text(),
      _1360: x0 => x0.arrayBuffer(),
      _1361: x0 => x0.getAsFile(),
      _1362: x0 => x0.webkitGetAsEntry(),
      _1363: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1363(f,arguments.length,x0) }),
      _1364: (x0,x1) => x0.getAsString(x1),
      _1365: x0 => x0.slice(),
      _1366: x0 => x0.cancel(),
      _1367: x0 => x0.stream(),
      _1368: x0 => new ReadableStreamDefaultReader(x0),
      _1369: x0 => x0.read(),
      _1370: x0 => x0.read(),
      _1371: x0 => ({type: x0}),
      _1372: (x0,x1) => new Blob(x0,x1),
      _1373: x0 => new ClipboardItem(x0),
      _1374: (x0,x1) => x0.write(x1),
      _1376: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1376(f,arguments.length,x0) }),
      _1377: x0 => x0.entries(),
      _1378: x0 => x0.next(),
      _1379: x0 => x0.getFile(),
      _1380: x0 => ({mode: x0}),
      _1381: (x0,x1) => x0.getReader(x1),
      _1382: x0 => new ArrayBuffer(x0),
      _1383: (x0,x1) => x0.read(x1),
      _1384: x0 => x0.done,
      _1385: x0 => x0.value,
      _1386: x0 => x0.click(),
      _1388: x0 => globalThis.URL.createObjectURL(x0),
      _1390: (x0,x1) => x0.createElement(x1),
      _1402: () => new FileReader(),
      _1403: (x0,x1) => x0.readAsArrayBuffer(x1),
      _1408: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1409: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      _1415: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1450: (x0,x1) => x0.querySelector(x1),
      _1451: (x0,x1) => x0.item(x1),
      _1453: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1453(f,arguments.length,x0) }),
      _1454: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1454(f,arguments.length,x0) }),
      _1455: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1455(f,arguments.length,x0) }),
      _1456: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1456(f,arguments.length,x0) }),
      _1457: (x0,x1) => x0.removeChild(x1),
      _1462: Date.now,
      _1463: secondsSinceEpoch => {
        const date = new Date(secondsSinceEpoch * 1000);
        const match = /\((.*)\)/.exec(date.toString());
        if (match == null) {
            // This should never happen on any recent browser.
            return '';
        }
        return match[1];
      },
      _1464: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _1465: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _1466: () => {
        let stackString = new Error().stack.toString();
        let frames = stackString.split('\n');
        let drop = 2;
        if (frames[0] === 'Error') {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _1467: () => typeof dartUseDateNowForTicks !== "undefined",
      _1468: () => 1000 * performance.now(),
      _1469: () => Date.now(),
      _1470: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      _1471: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      _1472: () => new WeakMap(),
      _1473: (map, o) => map.get(o),
      _1474: (map, o, v) => map.set(o, v),
      _1475: x0 => new WeakRef(x0),
      _1476: x0 => x0.deref(),
      _1477: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1477(f,arguments.length,x0) }),
      _1478: x0 => new FinalizationRegistry(x0),
      _1479: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      _1481: (x0,x1) => x0.unregister(x1),
      _1483: () => globalThis.WeakRef,
      _1484: () => globalThis.FinalizationRegistry,
      _1486: x0 => x0.call(),
      _1487: s => JSON.stringify(s),
      _1488: s => printToConsole(s),
      _1489: (o, p, r) => o.replaceAll(p, () => r),
      _1490: (o, p, r) => o.replace(p, () => r),
      _1491: Function.prototype.call.bind(String.prototype.toLowerCase),
      _1492: s => s.toUpperCase(),
      _1493: s => s.trim(),
      _1494: s => s.trimLeft(),
      _1495: s => s.trimRight(),
      _1496: (string, times) => string.repeat(times),
      _1497: Function.prototype.call.bind(String.prototype.indexOf),
      _1498: (s, p, i) => s.lastIndexOf(p, i),
      _1499: (string, token) => string.split(token),
      _1500: Object.is,
      _1501: o => o instanceof Array,
      _1502: (a, i) => a.push(i),
      _1506: a => a.pop(),
      _1507: (a, i) => a.splice(i, 1),
      _1508: (a, s) => a.join(s),
      _1509: (a, s, e) => a.slice(s, e),
      _1511: (a, b) => a == b ? 0 : (a > b ? 1 : -1),
      _1512: a => a.length,
      _1514: (a, i) => a[i],
      _1515: (a, i, v) => a[i] = v,
      _1517: o => {
        if (o instanceof ArrayBuffer) return 0;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 1;
        }
        return 2;
      },
      _1518: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _1519: o => o instanceof DataView,
      _1520: o => o instanceof Uint8Array,
      _1521: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _1522: o => o instanceof Int8Array,
      _1523: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _1524: o => o instanceof Uint8ClampedArray,
      _1525: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _1526: o => o instanceof Uint16Array,
      _1527: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _1528: o => o instanceof Int16Array,
      _1529: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _1530: o => o instanceof Uint32Array,
      _1531: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _1532: o => o instanceof Int32Array,
      _1533: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _1535: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      _1536: o => o instanceof Float32Array,
      _1537: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _1538: o => o instanceof Float64Array,
      _1539: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _1540: (t, s) => t.set(s),
      _1541: l => new DataView(new ArrayBuffer(l)),
      _1542: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _1543: o => o.byteLength,
      _1544: o => o.buffer,
      _1545: o => o.byteOffset,
      _1546: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _1547: (b, o) => new DataView(b, o),
      _1548: (b, o, l) => new DataView(b, o, l),
      _1549: Function.prototype.call.bind(DataView.prototype.getUint8),
      _1550: Function.prototype.call.bind(DataView.prototype.setUint8),
      _1551: Function.prototype.call.bind(DataView.prototype.getInt8),
      _1552: Function.prototype.call.bind(DataView.prototype.setInt8),
      _1553: Function.prototype.call.bind(DataView.prototype.getUint16),
      _1554: Function.prototype.call.bind(DataView.prototype.setUint16),
      _1555: Function.prototype.call.bind(DataView.prototype.getInt16),
      _1556: Function.prototype.call.bind(DataView.prototype.setInt16),
      _1557: Function.prototype.call.bind(DataView.prototype.getUint32),
      _1558: Function.prototype.call.bind(DataView.prototype.setUint32),
      _1559: Function.prototype.call.bind(DataView.prototype.getInt32),
      _1560: Function.prototype.call.bind(DataView.prototype.setInt32),
      _1563: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      _1564: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      _1565: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _1566: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _1567: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _1568: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _1569: x0 => x0.getDirectory(),
      _1570: x0 => ({create: x0}),
      _1571: (x0,x1,x2) => x0.getDirectoryHandle(x1,x2),
      _1572: x0 => ({create: x0}),
      _1573: (x0,x1,x2) => x0.getFileHandle(x1,x2),
      _1574: x0 => x0.createWritable(),
      _1575: x0 => x0.getWriter(),
      _1576: (x0,x1) => x0.write(x1),
      _1577: x0 => x0.close(),
      _1578: x0 => ({recursive: x0}),
      _1579: (x0,x1,x2) => x0.removeEntry(x1,x2),
      _1592: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _1593: (handle) => clearTimeout(handle),
      _1594: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      _1595: (handle) => clearInterval(handle),
      _1596: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _1597: () => Date.now(),
      _1598: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _1599: (x0,x1) => x0.exec(x1),
      _1600: (x0,x1) => x0.test(x1),
      _1601: x0 => x0.pop(),
      _1603: o => o === undefined,
      _1605: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _1607: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _1608: o => o instanceof RegExp,
      _1609: (l, r) => l === r,
      _1610: o => o,
      _1611: o => o,
      _1612: o => o,
      _1613: b => !!b,
      _1614: o => o.length,
      _1616: (o, i) => o[i],
      _1617: f => f.dartFunction,
      _1618: () => ({}),
      _1619: () => [],
      _1621: () => globalThis,
      _1622: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      _1623: (o, p) => p in o,
      _1624: (o, p) => o[p],
      _1625: (o, p, v) => o[p] = v,
      _1626: (o, m, a) => o[m].apply(o, a),
      _1628: o => String(o),
      _1629: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      _1630: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1630(f,arguments.length,x0) }),
      _1631: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1631(f,arguments.length,x0,x1) }),
      _1632: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      _1633: o => [o],
      _1634: (o0, o1) => [o0, o1],
      _1635: (o0, o1, o2) => [o0, o1, o2],
      _1636: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      _1637: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1638: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1639: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1640: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1641: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1642: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1643: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1644: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1645: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1646: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1647: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      _1649: x0 => x0.index,
      _1650: x0 => x0.groups,
      _1651: x0 => x0.flags,
      _1652: x0 => x0.multiline,
      _1653: x0 => x0.ignoreCase,
      _1654: x0 => x0.unicode,
      _1655: x0 => x0.dotAll,
      _1656: (x0,x1) => { x0.lastIndex = x1 },
      _1657: (o, p) => p in o,
      _1658: (o, p) => o[p],
      _1659: (o, p, v) => o[p] = v,
      _1662: x0 => x0.exports,
      _1663: (x0,x1) => globalThis.WebAssembly.instantiateStreaming(x0,x1),
      _1664: x0 => x0.instance,
      _1666: x0 => new WebAssembly.Memory(x0),
      _1667: x0 => x0.buffer,
      _1671: x0 => x0.sqlite3_initialize,
      _1673: (x0,x1,x2,x3,x4) => x0.sqlite3_open_v2(x1,x2,x3,x4),
      _1674: (x0,x1) => x0.sqlite3_close_v2(x1),
      _1675: (x0,x1,x2) => x0.sqlite3_extended_result_codes(x1,x2),
      _1676: (x0,x1) => x0.sqlite3_extended_errcode(x1),
      _1677: (x0,x1) => x0.sqlite3_errmsg(x1),
      _1678: (x0,x1) => x0.sqlite3_errstr(x1),
      _1679: x0 => x0.sqlite3_error_offset,
      _1683: (x0,x1) => x0.sqlite3_last_insert_rowid(x1),
      _1684: (x0,x1) => x0.sqlite3_changes(x1),
      _1685: (x0,x1,x2,x3,x4,x5) => x0.sqlite3_exec(x1,x2,x3,x4,x5),
      _1688: (x0,x1,x2,x3,x4,x5,x6) => x0.sqlite3_prepare_v3(x1,x2,x3,x4,x5,x6),
      _1689: (x0,x1) => x0.sqlite3_finalize(x1),
      _1690: (x0,x1) => x0.sqlite3_step(x1),
      _1691: (x0,x1) => x0.sqlite3_reset(x1),
      _1692: (x0,x1) => x0.sqlite3_stmt_isexplain(x1),
      _1694: (x0,x1) => x0.sqlite3_column_count(x1),
      _1695: (x0,x1) => x0.sqlite3_bind_parameter_count(x1),
      _1697: (x0,x1,x2) => x0.sqlite3_column_name(x1,x2),
      _1698: (x0,x1,x2,x3,x4,x5) => x0.sqlite3_bind_blob64(x1,x2,x3,x4,x5),
      _1699: (x0,x1,x2,x3) => x0.sqlite3_bind_double(x1,x2,x3),
      _1700: (x0,x1,x2,x3) => x0.sqlite3_bind_int64(x1,x2,x3),
      _1701: (x0,x1,x2) => x0.sqlite3_bind_null(x1,x2),
      _1702: (x0,x1,x2,x3,x4,x5) => x0.sqlite3_bind_text(x1,x2,x3,x4,x5),
      _1703: (x0,x1,x2) => x0.sqlite3_column_blob(x1,x2),
      _1704: (x0,x1,x2) => x0.sqlite3_column_double(x1,x2),
      _1705: (x0,x1,x2) => x0.sqlite3_column_int64(x1,x2),
      _1706: (x0,x1,x2) => x0.sqlite3_column_text(x1,x2),
      _1707: (x0,x1,x2) => x0.sqlite3_column_bytes(x1,x2),
      _1708: (x0,x1,x2) => x0.sqlite3_column_type(x1,x2),
      _1709: (x0,x1) => x0.sqlite3_value_blob(x1),
      _1710: (x0,x1) => x0.sqlite3_value_double(x1),
      _1711: (x0,x1) => x0.sqlite3_value_type(x1),
      _1712: (x0,x1) => x0.sqlite3_value_int64(x1),
      _1713: (x0,x1) => x0.sqlite3_value_text(x1),
      _1714: (x0,x1) => x0.sqlite3_value_bytes(x1),
      _1717: (x0,x1) => x0.sqlite3_user_data(x1),
      _1718: (x0,x1,x2,x3,x4) => x0.sqlite3_result_blob64(x1,x2,x3,x4),
      _1719: (x0,x1,x2) => x0.sqlite3_result_double(x1,x2),
      _1720: (x0,x1,x2,x3) => x0.sqlite3_result_error(x1,x2,x3),
      _1721: (x0,x1,x2) => x0.sqlite3_result_int64(x1,x2),
      _1722: (x0,x1) => x0.sqlite3_result_null(x1),
      _1723: (x0,x1,x2,x3,x4) => x0.sqlite3_result_text(x1,x2,x3,x4),
      _1724: x0 => x0.sqlite3_result_subtype,
      _1743: (x0,x1) => x0.dart_sqlite3_malloc(x1),
      _1744: (x0,x1) => x0.dart_sqlite3_free(x1),
      _1745: (x0,x1,x2,x3) => x0.dart_sqlite3_register_vfs(x1,x2,x3),
      _1746: (x0,x1,x2,x3,x4,x5) => x0.dart_sqlite3_create_scalar_function(x1,x2,x3,x4,x5),
      _1749: x0 => x0.dart_sqlite3_updates,
      _1750: x0 => x0.dart_sqlite3_commits,
      _1751: x0 => x0.dart_sqlite3_rollbacks,
      _1755: x0 => ({initial: x0}),
      _1756: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1756(f,arguments.length,x0) }),
      _1757: f => finalizeWrapper(f, function(x0,x1,x2,x3,x4) { return dartInstance.exports._1757(f,arguments.length,x0,x1,x2,x3,x4) }),
      _1758: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1758(f,arguments.length,x0,x1,x2) }),
      _1759: f => finalizeWrapper(f, function(x0,x1,x2,x3) { return dartInstance.exports._1759(f,arguments.length,x0,x1,x2,x3) }),
      _1760: f => finalizeWrapper(f, function(x0,x1,x2,x3) { return dartInstance.exports._1760(f,arguments.length,x0,x1,x2,x3) }),
      _1761: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1761(f,arguments.length,x0,x1,x2) }),
      _1762: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1762(f,arguments.length,x0,x1) }),
      _1763: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1763(f,arguments.length,x0,x1) }),
      _1764: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1764(f,arguments.length,x0) }),
      _1765: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1765(f,arguments.length,x0) }),
      _1766: f => finalizeWrapper(f, function(x0,x1,x2,x3) { return dartInstance.exports._1766(f,arguments.length,x0,x1,x2,x3) }),
      _1767: f => finalizeWrapper(f, function(x0,x1,x2,x3) { return dartInstance.exports._1767(f,arguments.length,x0,x1,x2,x3) }),
      _1768: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1768(f,arguments.length,x0,x1) }),
      _1769: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1769(f,arguments.length,x0,x1) }),
      _1770: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1770(f,arguments.length,x0,x1) }),
      _1771: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1771(f,arguments.length,x0,x1) }),
      _1772: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1772(f,arguments.length,x0,x1) }),
      _1773: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1773(f,arguments.length,x0,x1) }),
      _1774: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1774(f,arguments.length,x0,x1,x2) }),
      _1775: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1775(f,arguments.length,x0,x1,x2) }),
      _1776: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1776(f,arguments.length,x0,x1,x2) }),
      _1777: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1777(f,arguments.length,x0) }),
      _1778: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1778(f,arguments.length,x0) }),
      _1779: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1779(f,arguments.length,x0) }),
      _1780: f => finalizeWrapper(f, function(x0,x1,x2,x3,x4) { return dartInstance.exports._1780(f,arguments.length,x0,x1,x2,x3,x4) }),
      _1781: f => finalizeWrapper(f, function(x0,x1,x2,x3,x4) { return dartInstance.exports._1781(f,arguments.length,x0,x1,x2,x3,x4) }),
      _1782: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1782(f,arguments.length,x0) }),
      _1783: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1783(f,arguments.length,x0) }),
      _1784: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1784(f,arguments.length,x0,x1) }),
      _1785: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1785(f,arguments.length,x0,x1) }),
      _1786: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1786(f,arguments.length,x0,x1,x2) }),
      _1788: (x0,x1,x2,x3) => x0.call(x1,x2,x3),
      _1793: x0 => new URL(x0),
      _1794: (x0,x1) => new URL(x0,x1),
      _1795: (x0,x1) => globalThis.fetch(x0,x1),
      _1796: (x0,x1,x2) => x0.postMessage(x1,x2),
      _1797: (x0,x1,x2) => x0.postMessage(x1,x2),
      _1799: (x0,x1) => ({i: x0,p: x1}),
      _1800: (x0,x1) => ({c: x0,r: x1}),
      _1801: x0 => x0.i,
      _1802: x0 => x0.p,
      _1803: x0 => x0.c,
      _1804: x0 => x0.r,
      _1805: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1805(f,arguments.length,x0) }),
      _1806: (x0,x1) => x0.postMessage(x1),
      _1807: x0 => x0.close(),
      _1809: x0 => new Worker(x0),
      _1811: x0 => x0.createSyncAccessHandle(),
      _1812: x0 => x0.close(),
      _1815: x0 => x0.close(),
      _1816: (x0,x1) => x0.deleteDatabase(x1),
      _1818: (x0,x1,x2) => x0.open(x1,x2),
      _1819: x0 => x0.abort(),
      _1828: (x0,x1) => new SharedWorker(x0,x1),
      _1829: x0 => x0.start(),
      _1830: x0 => x0.terminate(),
      _1831: () => new MessageChannel(),
      _1834: x0 => new SharedArrayBuffer(x0),
      _1835: x0 => ({at: x0}),
      _1836: x0 => x0.getSize(),
      _1837: (x0,x1) => x0.truncate(x1),
      _1838: x0 => x0.flush(),
      _1841: x0 => x0.synchronizationBuffer,
      _1842: x0 => x0.communicationBuffer,
      _1843: (x0,x1,x2,x3) => ({clientVersion: x0,root: x1,synchronizationBuffer: x2,communicationBuffer: x3}),
      _1844: (x0,x1) => globalThis.IDBKeyRange.bound(x0,x1),
      _1845: x0 => ({autoIncrement: x0}),
      _1846: (x0,x1,x2) => x0.createObjectStore(x1,x2),
      _1847: x0 => ({unique: x0}),
      _1848: (x0,x1,x2,x3) => x0.createIndex(x1,x2,x3),
      _1849: (x0,x1) => x0.createObjectStore(x1),
      _1850: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1850(f,arguments.length,x0) }),
      _1851: (x0,x1,x2) => x0.transaction(x1,x2),
      _1852: (x0,x1) => x0.objectStore(x1),
      _1854: (x0,x1) => x0.index(x1),
      _1855: x0 => x0.openKeyCursor(),
      _1856: (x0,x1) => x0.getKey(x1),
      _1857: (x0,x1) => ({name: x0,length: x1}),
      _1858: (x0,x1) => x0.put(x1),
      _1859: (x0,x1) => x0.get(x1),
      _1860: (x0,x1) => x0.openCursor(x1),
      _1861: x0 => globalThis.IDBKeyRange.only(x0),
      _1862: (x0,x1,x2) => x0.put(x1,x2),
      _1863: (x0,x1) => x0.update(x1),
      _1864: (x0,x1) => x0.delete(x1),
      _1865: x0 => x0.name,
      _1866: x0 => x0.length,
      _1869: x0 => x0.continue(),
      _1870: () => globalThis.indexedDB,
      _1871: () => globalThis.navigator,
      _1872: (x0,x1) => x0.read(x1),
      _1873: (x0,x1,x2) => x0.read(x1,x2),
      _1874: (x0,x1) => x0.write(x1),
      _1875: (x0,x1,x2) => x0.write(x1,x2),
      _1877: (x0,x1,x2) => globalThis.Atomics.wait(x0,x1,x2),
      _1879: (x0,x1,x2) => globalThis.Atomics.notify(x0,x1,x2),
      _1880: (x0,x1,x2) => globalThis.Atomics.store(x0,x1,x2),
      _1881: (x0,x1) => globalThis.Atomics.load(x0,x1),
      _1882: () => globalThis.Int32Array,
      _1884: () => globalThis.Uint8Array,
      _1886: () => globalThis.DataView,
      _1888: x0 => x0.byteLength,
      _1890: x0 => globalThis.BigInt(x0),
      _1891: x0 => globalThis.Number(x0),
      _1898: (x0,x1) => x0.getAllKeys(x1),
      _1899: (x0,x1) => x0.getAll(x1),
      _1900: (x0,x1) => x0.contains(x1),
      _1901: (x0,x1) => x0.deleteObjectStore(x1),
      _1902: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1902(f,arguments.length,x0) }),
      _1903: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1903(f,arguments.length,x0) }),
      _1904: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1904(f,arguments.length,x0) }),
      _1906: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1906(f,arguments.length,x0) }),
      _1910: x0 => globalThis.Array.isArray(x0),
      _1911: x0 => x0.close(),
      _1912: (x0,x1) => ({kind: x0,table: x1}),
      _1913: x0 => x0.kind,
      _1914: x0 => x0.table,
      _1922: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1922(f,arguments.length,x0) }),
      _1923: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1923(f,arguments.length,x0) }),
      _1931: () => new AbortController(),
      _1932: x0 => x0.abort(),
      _1933: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      _1934: (x0,x1) => globalThis.fetch(x0,x1),
      _1935: (x0,x1) => x0.get(x1),
      _1936: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1936(f,arguments.length,x0,x1,x2) }),
      _1937: (x0,x1) => x0.forEach(x1),
      _1938: x0 => x0.getReader(),
      _1939: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1939(f,arguments.length,x0) }),
      _1940: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1940(f,arguments.length,x0) }),
      _1941: x0 => x0.openCursor(),
      _1942: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1942(f,arguments.length,x0) }),
      _1943: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1943(f,arguments.length,x0) }),
      _1956: x0 => x0.random(),
      _1957: (x0,x1) => x0.getRandomValues(x1),
      _1958: () => globalThis.crypto,
      _1959: () => globalThis.Math,
      _1970: Function.prototype.call.bind(Number.prototype.toString),
      _1971: Function.prototype.call.bind(BigInt.prototype.toString),
      _1972: Function.prototype.call.bind(Number.prototype.toString),
      _1973: (d, digits) => d.toFixed(digits),
      _2105: x0 => x0.length,
      _2128: (x0,x1) => { x0.draggable = x1 },
      _2144: x0 => x0.style,
      _2501: (x0,x1) => { x0.target = x1 },
      _2503: (x0,x1) => { x0.download = x1 },
      _2528: (x0,x1) => { x0.href = x1 },
      _3073: (x0,x1) => { x0.accept = x1 },
      _3087: x0 => x0.files,
      _3113: (x0,x1) => { x0.multiple = x1 },
      _3131: (x0,x1) => { x0.type = x1 },
      _3828: (x0,x1) => { x0.dropEffect = x1 },
      _3829: x0 => x0.effectAllowed,
      _3831: x0 => x0.items,
      _3832: x0 => x0.types,
      _3834: (x0,x1) => x0[x1],
      _3838: x0 => x0.length,
      _3839: x0 => x0.kind,
      _3840: x0 => x0.type,
      _3842: x0 => x0.dataTransfer,
      _3846: () => globalThis.window,
      _3885: x0 => x0.self,
      _3886: x0 => x0.document,
      _3889: x0 => x0.location,
      _3908: x0 => x0.navigator,
      _4165: x0 => x0.indexedDB,
      _4181: (x0,x1) => { x0.href = x1 },
      _4274: x0 => x0.clipboard,
      _4276: x0 => x0.geolocation,
      _4279: x0 => x0.mediaDevices,
      _4281: x0 => x0.permissions,
      _4295: x0 => x0.userAgent,
      _4308: x0 => x0.storage,
      _4346: x0 => x0.data,
      _4376: x0 => x0.port1,
      _4377: x0 => x0.port2,
      _4379: (x0,x1) => { x0.onmessage = x1 },
      _4389: (x0,x1) => { x0.onmessage = x1 },
      _4457: x0 => x0.port,
      _6399: x0 => x0.target,
      _6439: x0 => x0.signal,
      _6494: x0 => x0.baseURI,
      _6500: x0 => x0.firstChild,
      _6511: () => globalThis.document,
      _6924: (x0,x1) => { x0.id = x1 },
      _6951: x0 => x0.children,
      _7266: x0 => x0.pageX,
      _7267: x0 => x0.pageY,
      _7270: x0 => x0.offsetX,
      _7271: x0 => x0.offsetY,
      _8267: x0 => x0.value,
      _8269: x0 => x0.done,
      _8392: x0 => x0.name,
      _8423: x0 => x0.size,
      _8424: x0 => x0.type,
      _8430: x0 => x0.name,
      _8436: x0 => x0.length,
      _8441: x0 => x0.result,
      _8937: x0 => x0.url,
      _8939: x0 => x0.status,
      _8941: x0 => x0.statusText,
      _8942: x0 => x0.headers,
      _8943: x0 => x0.body,
      _9014: x0 => x0.clipboardData,
      _9018: x0 => x0.types,
      _10392: x0 => x0.result,
      _10393: x0 => x0.error,
      _10395: x0 => x0.transaction,
      _10398: (x0,x1) => { x0.onsuccess = x1 },
      _10400: (x0,x1) => { x0.onerror = x1 },
      _10404: (x0,x1) => { x0.onupgradeneeded = x1 },
      _10406: x0 => x0.oldVersion,
      _10420: x0 => x0.name,
      _10421: x0 => x0.version,
      _10422: x0 => x0.objectStoreNames,
      _10484: x0 => x0.key,
      _10485: x0 => x0.primaryKey,
      _10487: x0 => x0.value,
      _11325: (x0,x1) => { x0.display = x1 },
      _12547: x0 => x0.name,

    };

    const baseImports = {
      dart2wasm: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      S: new Proxy({}, { get(_, prop) { return prop; } }),

    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      "intoCharCodeArray": (s, a, start) => {
        if (s === '') return 0;

        const write = dartInstance.exports.$wasmI16ArraySet;
        for (var i = 0; i < s.length; ++i) {
          write(a, start++, s.charCodeAt(i));
        }
        return s.length;
      },
      "test": (s) => typeof s == "string",
    };


    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
      "wasm:js-string": jsStringPolyfill,
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
