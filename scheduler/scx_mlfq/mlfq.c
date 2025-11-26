#include "mlfq.h"

void init_queue(Queue *q){
    q->front = 0; 
    q->rear = -1; 
    q->count = 0; 
}

void enqueue(Queue *q, Process *t){ 
    if(q->count < MAX_PROCESS){ 
        q->rear = (q->rear++)%MAX_PROCESS; 
        q->task[q->rear] = t; 
        q->count ++; 
    }
}

Process* dequeue(Queue *q){
    if(q->count ==0 )
        return NULL; 
    Process *t = q->task[q->front++];
    q->front = (q->front++)%MAX_PROCESS; 
    q->count--;
    return t;
}

void run_mlfq(){
    
}