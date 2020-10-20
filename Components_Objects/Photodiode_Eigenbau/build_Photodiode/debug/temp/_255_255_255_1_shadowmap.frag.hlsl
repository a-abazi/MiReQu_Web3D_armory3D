void frag_main()
{
    float opacity = 0.399800002574920654296875f;
    if (opacity < 1.0f)
    {
        discard;
    }
}

void main()
{
    frag_main();
}
