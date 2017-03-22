/*
 * =======================================================================
 * ldml_computetasks.c 
 *
 * Multi-threading
 *
 * Matthijs Douze, INRIA
 * =======================================================================
 */

#include <pthread.h>
#include <stdlib.h>


typedef struct {
  pthread_mutex_t mutex;
  int i, n, tid;
  void (*task_fun) (void *arg, int tid, int i);
  void *task_arg;
} context_t;



static void *start_routine (void *cp)
{
  context_t *context = cp;
  int tid;
  pthread_mutex_lock (&context->mutex);
  tid = context->tid++;
  pthread_mutex_unlock (&context->mutex);

  for (;;) {
    int item;
    pthread_mutex_lock (&context->mutex);
    item = context->i++;
    pthread_mutex_unlock (&context->mutex);
    if (item >= context->n)
      break;
    else
      context->task_fun (context->task_arg, tid, item);
  }

  return NULL;
}

void compute_tasks (int n, int nthread,
                    void (*task_fun) (void *arg, int tid, int i),
                    void *task_arg)
{
  int i;
  context_t context;
  pthread_t *threads = malloc (sizeof (pthread_t) * nthread);

  pthread_mutex_init (&context.mutex, NULL);

  context.i = 0;
  context.n = n;
  context.tid = 0;
  context.task_fun = task_fun;
  context.task_arg = task_arg;

  for (i = 0; i < nthread; i++)
    pthread_create (&threads[i], NULL, &start_routine, &context);

  /* all computing */

  for (i = 0; i < nthread; i++)
    pthread_join (threads[i], NULL);

  free (threads);
}
