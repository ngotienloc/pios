// File: ~/pios/scheduler/mlfq.h

#ifndef _LINUX_MLFQ_H
#define _LINUX_MLFQ_H

#include <linux/list.h>


// Định nghĩa số lượng hàng đợi
#define MLFQ_NUM_QUEUES 5
#define MLFQ_MAX_PRIO   (MLFQ_NUM_QUEUES - 1)

// Cấu trúc MLFQ Runqueue (Mỗi CPU có một)
struct mlfq_rq {
    struct list_head queues[MLFQ_NUM_QUEUES]; // Mảng 5 hàng đợi
    int highest_prio;                         // Mức ưu tiên cao nhất đang có task
    int nr_running;                           // Tổng số task trong MLFQ
};

// Cấu trúc Thông tin MLFQ được nhúng vào struct task_struct
struct mlfq_task_info {
    int current_prio;       // Mức ưu tiên hiện tại (0-4)
    unsigned long time_slice; // Thời gian còn lại được chạy
    unsigned long burst_time; // Thời gian CPU đã sử dụng trong level hiện tại (để tính demotion)
    unsigned long total_wait_time; // Thời gian chờ (để tính aging)
    struct list_head mlfq_list; // Node liên kết trong hàng đợi MLFQ
};

// Khai báo các hàm Scheduler Class Interface (sẽ được định nghĩa trong mlfq.c)
extern void enqueue_task_mlfq(struct rq *rq, struct task_struct *p, int flags);
extern void dequeue_task_mlfq(struct rq *rq, struct task_struct *p, int flags);
extern struct task_struct *pick_next_task_mlfq(struct rq *rq);
extern void put_prev_task_mlfq(struct rq *rq, struct task_struct *prev);
extern void task_tick_mlfq(struct rq *rq, struct task_struct *p, int queued);
extern void set_curr_task_mlfq(struct rq *rq);
extern void switched_to_mlfq(struct rq *rq, struct task_struct *p);

#endif /* _LINUX_MLFQ_H */