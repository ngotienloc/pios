#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <sys/time.h>

#define N 20
#define CPU_TASK 0
#define IO_TASK 1

long long now() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * 1000000LL + tv.tv_usec;
}

void cpu_bound_work() {
    volatile unsigned long long x = 0;
    for (unsigned long long i = 0; i < 5e8; i++) {
        x += i;
    }
}

void io_like_work() {
    for (int i = 0; i < 300; i++) {
        volatile unsigned long long x = i * i;
        usleep(2000);  // sleep 2ms -> giống "interactive"
    }
}

int main() {
    pid_t pid;
    long long start = now();

    for (int i = 0; i < N; i++) {
        pid = fork();
        if (pid == 0) {
            long long t0 = now();
            if (i % 2 == 0) {  // 10 CPU-bound
                cpu_bound_work();
            } else {           // 10 interactive
                io_like_work();
            }
            long long t1 = now();
            printf("Child %d (%s) finished in %.2f ms\n",
                   i,
                   (i % 2 == 0) ? "CPU" : "IO",
                   (t1 - t0) / 1000.0);
            fflush(stdout);
            exit(0);
        }
    }

    // Parent: wait all
    for (int i = 0; i < N; i++) wait(NULL);

    printf("\n=== DONE ===\n");
    return 0;
}
