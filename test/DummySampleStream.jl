@testset "DummySampleStream Tests" begin
    const DEFAULT_SR = 48000Hz
    const DEFAULT_T = Float32

    DummySource(buf) = DummySampleSource(DEFAULT_SR, buf)
    DummyMonoSink() = DummySampleSink(DEFAULT_T, DEFAULT_SR, 1)
    DummyStereoSink() = DummySampleSink(DEFAULT_T, DEFAULT_SR, 2)

    @testset "write writes to buf" begin
        sink = DummyStereoSink()
        buf = SampleBuf(convert(Array{DEFAULT_T}, randn(32, 2)), DEFAULT_SR)
        write(sink, buf)
        @test sink.buf == buf.data
    end

    @testset "read reads from buf" begin
        data = rand(DEFAULT_T, (64, 2))
        source = DummySource(data)
        buf = read(source, 64)
        @test buf.data == data
    end

    @testset "read can read in seconds" begin
        # fill with 1s of data
        data = rand(DEFAULT_T, (DEFAULT_SR*1s, 2))
        source = DummySource(data)
        buf = read(source, 0.0005s)
        @test buf.data == data[1:round(Int, 0.0005s*DEFAULT_SR), :]
    end

    @testset "supports audio interface" begin
        data = rand(DEFAULT_T, (64, 2))
        source = DummySource(data)
        @test samplerate(source) == DEFAULT_SR
        @test nchannels(source) == 2
        sink = DummyStereoSink()
        @test samplerate(sink) == DEFAULT_SR
        @test nchannels(sink) == 2
        @test eltype(source) == DEFAULT_T
    end

    @testset "can be created with non-unit sampling rate" begin
        sink = DummySampleSink(Float32, 48000, 2)
        @test samplerate(sink) == 48000
        source = DummySampleSource(48000, Array(Float32, 16, 2))
        @test samplerate(source) == 48000
    end
end
