#if os(Linux)
#if GLES
    import COpenGLES.gles2
    #else
    import COpenGL
#endif
#else
#if GLES
    import OpenGLES
    #else
    import OpenGL.GL3
#endif
#endif

public enum PixelFormat {
    case bgra
    case rgba
    case rgb
    case luminance
    
    func toGL() -> Int32 {
        switch self {
            case .bgra: return GL_BGRA
            case .rgba: return GL_RGBA
            case .rgb: return GL_RGB
            case .luminance: return GL_LUMINANCE
        }
    }
}

// TODO: Replace with texture caches where appropriate
public class RawDataInput: ImageSource {
    public let targets = TargetContainer()
    // MARK: - PR #30
    private var privatePixelFormat = PixelFormat.rgba
    
    public init() {
        
    }

    public func uploadBytes(_ bytes:[UInt8], size:Size, pixelFormat:PixelFormat, orientation:ImageOrientation = .portrait) {
        privatePixelFormat = pixelFormat == .luminance ? PixelFormat.rgba : pixelFormat
        let dataFramebuffer = sharedImageProcessingContext.framebufferCache.requestFramebufferWithProperties(orientation:orientation, size:GLSize(size), textureOnly:true, internalFormat:pixelFormat.toGL(), format:pixelFormat.toGL())

        glActiveTexture(GLenum(GL_TEXTURE1))
        glBindTexture(GLenum(GL_TEXTURE_2D), dataFramebuffer.texture)
        // MARK: - PR #30
        //glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, size.glWidth(), size.glHeight(), 0, GLenum(pixelFormat.toGL()), GLenum(GL_UNSIGNED_BYTE), bytes)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, size.glWidth(), size.glHeight(), 0, GLenum(privatePixelFormat.toGL()), GLenum(GL_UNSIGNED_BYTE), bytes)

        updateTargetsWithFramebuffer(dataFramebuffer)
    }
    
    public func transmitPreviousImage(to target:ImageConsumer, atIndex:UInt) {
        // TODO: Determine if this is necessary for the raw data uploads
    }
}
