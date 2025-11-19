#ifndef _MLFQ_H 
#define _MLFQ_H

#include <linux/sched.h>
#include <linux/list.h>

// Define basic parameter for MLFQ:
#define MLFQ_NUM_QUEUES     5     // Number of queues 
#define MLFQ_DEFAULT_LEVEL  4     // Hihgest priority for new tastk 
#define MLFQ_TIMESLICE_MS   10    // Time slice basic (10ms)
#define MLFQ_AGING_LIMIT    (10 * HZ) // Max waiting time
  


#endif