extern void traktorRemoteInit(void);

__attribute__((constructor))
static void init(void) {
    traktorRemoteInit();
}
