#include <stdint.h>
#define SDRAM_BASE 0x00000000u
#define TEST_ADDR  (SDRAM_BASE + 0x1000)

int main(void){
    volatile uint32_t *p = (uint32_t*)TEST_ADDR;
    *p = 0x12345678;
    volatile uint32_t r = *p;
    if(r == 0x12345678){
        *p = 0x87654321;
    }
    for(;;){ __asm__ volatile("wfi"); }
}
