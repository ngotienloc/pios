#ifndef MLFQ_H
#define MLFQ_H

#define MAX_QUEUE 3
#define MAX_PROCESS 100

#define TIME_SLIDE_Q0 2 
#define TIME_SLIDE_Q1 4
#define TIME_SLIDE_q2 8

#include <stdio.h>

typedef struct Process { 
    int pid;            
    int arrival_time; 
    int burst_time;
    int queue_level; 
} Process;  

typedef struct Queue {
    Process *task[MAX_PROCESS]; 
    int front; 
    int rear; 
    int count; 
} Queue; 

void init_queue(Queue *q); 

void enqueue(Queue *q, Process *t);

Process* deqeue(Queue *q); 

void run_mlfq(Process process[], int n_task, int n_queue); 
#endif