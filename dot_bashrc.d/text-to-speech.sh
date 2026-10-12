# test with `echo "hello-world" | kokoro-tts - --stream``
kokoro-tts() {
    command kokoro-tts "$@" \
        --model ~/.local/models/kokoro-v1.0.onnx \
        --voices ~/.local/models/voices-v1.0.bin \
        --speed 0.8 \
        --format mp3
}