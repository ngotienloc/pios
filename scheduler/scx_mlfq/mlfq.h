#ifndef MLFQ_H
#define MLFQ_H

#define MAX_QUEUE 3
#define MAX_TASK 100
#define TIME_SLIDE 5

typedef struct Task { 
    int pid;            // id task 
    int arrival_time; 
    int burst_time;
} Task;  

typedef struct Queue {
    Task *task[MAX_TASK]; 
    int front; 
    int rear; 
    int count; 
} Queue; 

#endif