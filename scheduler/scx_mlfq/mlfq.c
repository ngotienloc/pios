#include "mlfq.h"

void init_queue(Queue *q){
    q->front = -1; 
    q->rear = -1; 
    q->count = 0; 
}
// Chua co phuong an xu ly co che task khi full, tam thoi quay vong
void enqueue(Queue *q, Process *t){
    if(q == NULL)
        return; 
    if(q->front == -1) 
        q->front = 0; 
    q->rear = (q->rear+1)%MAX_PROCESS; 
    q->count++; 
    q->task[q->rear] = t; 
}

Process *deqeue(Queue *q){
    Process *t; 
    if(q==NULL)
        return NULL; 
    if(q->front == -1)
        return NULL;
    t = q->task[q->front]; 
    q->front = (q->front+1)%MAX_PROCESS; 
    q->count--; 
    return t; 
}

void run_mlfq(Process process[], int n_task, int n_queue){
    
}