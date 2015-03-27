package {
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import asgl.shaders.scripts.compiler.ShaderScriptCompiler;
	
	public class ASGL_ShaderBuilder extends Sprite {
		private var _index:uint;
		private var _srcRoot:String;
		private var _releaseRoot:String;
		private var _compiler:ShaderScriptCompiler;
		
		public function ASGL_ShaderBuilder() {
			_compiler = new ShaderScriptCompiler();
			
			var f:File = new File(File.applicationDirectory.nativePath);
			
			var root:String = f.parent.nativePath + '/res';
			var srcRoot:String = root + '/src';
			_releaseRoot = root + '/release';
			
			_index = srcRoot.length;
			
			var releaseDir:File = new File(_releaseRoot);
			if (releaseDir.exists) releaseDir.deleteDirectory(true);
			
			f = new File(srcRoot);
			if (f.exists) {
				_compile(f);
			}
		}
		private function _compile(dir:File):void {
			var files:Array = dir.getDirectoryListing();
			var len:uint = files.length;
			for (var i:uint = 0; i < len; i++) {
				var f:File = files[i];
				if (f.isDirectory) {
					_compile(f);
				} else {
//					var parentName:String = 'spine';
//					var parentName:String = 'deferredlighting';
//					var parentName:String = 'forward';
//					var parentName:String = 'deferredshading';
//					var parentName:String = 'others';
//					var parentName:String = 'particles';
//					var parentName:String = 'src';
					var parentName:String = 'priorityfill';
					if (f.parent.name != parentName) continue;
					if (f.nativePath.indexOf('') == -1 || f.name != 'ConstantBatchColorShader.res') continue;
					
					trace('\n' + f.nativePath);
					
					var bytes:ByteArray = _readBytes(f.nativePath);
					
					bytes = _compiler.compile(bytes.readUTFBytes(bytes.length), true);
					
					var path:String = _releaseRoot + f.nativePath.substr(_index);
					if (f.extension == '') {
						if (path.charAt(path.length - 1) != '.') path += '.';
					} else {
						path = path.substr(0, path.lastIndexOf('.') + 1);
					}
					
					path += 'bin';
					
					_writeBytes(path, bytes);
				}
			}
		}
		private function _readBytes(path:String):ByteArray {
			var bytes:ByteArray = new ByteArray();
			
			var s:FileStream = new FileStream();
			s.open(new File(path), FileMode.READ);
			s.readBytes(bytes);
			s.close();
			
			return bytes;
		}
		private function _writeBytes(path:String, bytes:ByteArray):void {
			var s:FileStream = new FileStream();
			s.open(new File(path), FileMode.WRITE);
			s.writeBytes(bytes);
			s.close();
		}
	}
}