#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#define max_task 10 
#define queues 4 

// Queue Structure
typedef struct{
    int pid; // id tasks  
    int burst_time; //time resolve tasks 
    int remaining_time; // Time remain
    int arrival_time; 
    int compeleted; 
} Process; 

typedef struct { 
   int items[max_task];
   int front, rear;  
} Queue; 

void inqueue(Queue *q){
    q->front = q->rear = 0; 
}

bool fullqueue(Queue *q){
    return ((q->rear+1)%max_task == q->front); 
}

bool emptyqueue(Queue *q){
    return (q->front == q->rear); 
}

void enqueue(Queue *q, int pid){
    if(fullqueue(q))
        return; 
    q->rear=(q->rear+1)%max_task;
    q->items[q->rear] = pid; 
}

void dequeue(Queue *q){
    if(emptyqueue(q))
        return; 
    q->front = (q->front+1)%max_task; 
}

int main(){
    Queue q[queues]; 
    int time_quantum[queues] = {2, 4, 8}; 
    Process p[max_task]; 

    //init queue 
    for(int i = 0; i < queues ; i++)
        inqueue(&q[i]); 
    
    Queue *DSQ = (Queue* )malloc(sizeof(Queue)); 
    inqueue(DSQ); 

}