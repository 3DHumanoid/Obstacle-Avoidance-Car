#include "msp.h"

//Wiring:
//
//    PWM:
//    P2.7 = enB
//    P2.6 = enA
//    P2.4 = Servo
//
//    Motor:
//    P2.3 = M1For
//    P2.5 = M1Back
//    P6.6 = M2For
//    P6.7 = M2Back
//
//    Sensor:
//    P3.7 = FSen
//    P3.6 = FLSen
//    P3.5 = FRSen
//    P3.0 = FDSen
//    P5.7 = BSen
//    P5.6 = BLSen
//    P5.1 = BRSen
//    P5.0 = BDSen



//Motors
#define enB BIT7
#define enA BIT6
#define MRFor BIT5
#define MRBack BIT3
#define MLFor BIT6
#define MLBack BIT7

//Servo
#define Servo BIT4

//Sensors
#define FSen BIT7
#define FLSen BIT6
#define FRSen BIT5
#define BSen BIT7
#define BLSen BIT6
#define BRSen BIT1
#define FDSen BIT0
#define BDSen BIT0

#define DELAY 500

int i;
int Rand = 0;

int Servo_period = 20000;
int Motor_period = 10000;
int period = 20000;
float D = 0.1f;

void main(void)
{
    WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD;     // stop watchdog timer

//    CS->KEY= CS_KEY_VAL; // Set the REFO frequency to 32khz
//    CS->CTL1 = CS_CTL1_SELM_2 | CS_CTL1_DIVM_1; // Initialize Master Clock
//    CS->KEY = 0;
//
//    while (PCM->CTL1 & PCM_CTL1_PMR_BUSY);
//    PCM->CTL0 = PCM_CTL0_KEY_VAL |PCM_CTL0_AMR_8; // Set the Power Control Module to active mode, low frequency, and Vcore level 0
//    while (PCM->CTL1 & PCM_CTL1_PMR_BUSY);

    P2->DIR |= 0xF8; //Set P2. 7,6,5,4,3 as OUTPUT
    P3->DIR |= 0x00; //Set P3. 7,6,5,0 as INPUT
    P5->DIR |= 0x00; //Set P5. 7,6,1,0 as INPUT
    P6->DIR |= 0xC0; //Set P6. 6,7 as OUTPUT

    P2->SEL0 |= 0xD0; // Set P2.7, P2.6, P2.4 as PWM

    //INTURRUPT CONFIG
    P5->REN |= 0xC3;
    P5->OUT |= 0xC3;
    P5->IE |= 0xC3;
    P5->IES |= 0xC3;
    P5->IFG = 0x00;

    P3->REN |= 0xE1;
    P3->OUT |= 0xE1;
    P3->IE |= 0xE1;
    P3->IES |= 0xE1;
    P3->IFG = 0x00;

    //Motor Configuration
    P2->OUT |= MRFor;
    P2->OUT &= ~MRBack;

    P6->OUT |= MLFor;
    P6->OUT &= ~MLBack;

    P2->DIR |= BIT0;
    P2->DIR |= BIT1;


//    //Button
    P1->DIR = 0x00;
    P1->REN = BIT1;
    P1->OUT = BIT1;
    P1->IE = BIT1;
    P1->IES = 0x00;
    P1->IFG = 0x00;


    TIMER_A0->CCR[0] = period-1; //PWM period
    TIMER_A0->CCR[1] = 5000; // CCR1 PWM duty cycle (Servo)
    TIMER_A0->CCR[3] = Motor_period; // CCR3 PWM duty cycle (Right)
    TIMER_A0->CCR[4] = Motor_period; // CCR3 PWM duty cycle (Left)
    TIMER_A0->CCTL[1] = TIMER_A_CCTLN_OUTMOD_7; // CCR1 reset/set
    TIMER_A0->CCTL[3] = TIMER_A_CCTLN_OUTMOD_7; // CCR1 reset/set
    TIMER_A0->CCTL[4] = TIMER_A_CCTLN_OUTMOD_7; // CCR1 reset/set
    TIMER_A0->CTL = TIMER_A_CTL_TASSEL_2 | TIMER_A_CTL_MC_1 |
            TIMER_A_CTL_CLR; //SMCLK Up mode, Clear TAR


    NVIC->ISER[1] = 0x00000008; //Port 1
    _enable_interrupts();

    NVIC->ISER[1] = 0x00000020;
        _enable_interrupts();

    NVIC->ISER[1] = 0x00000080;
            _enable_interrupts();

    //Delay();

    SCB->SCR |= SCB_SCR_SLEEPONEXIT_Msk;
    __sleep();


}



//BUTTON INTURRUPT
void PORT1_IRQHandler(void)
{
    if(P1->IFG & BIT1){
        if(D >= 1.0f) D = 0.0f;
        else D += 0.1f;

        TIMER_A0->CCR[1] = period*D;
        TIMER_A0->CCR[3] = period*D;
        TIMER_A0->CCR[4] = period*D;
    }

    for(i=0;i<DELAY;i++){}
    P1->IFG &= ~BIT1;


}

//Front Sensor
void PORT3_IRQHandler(void)
{
    //Front Sensor
    if(P3->IFG & FSen){

        Stop();
        Backward();
        TurnRight();
        SpeedUp();

        if((P3->IES & FSen) == 0)
        {
            Forward();
        }

        P3->IFG &= ~FSen;
        P3->IES ^= FSen;

        for(i=0;i<DELAY;i++){}
    }
    //Front Right Sensor
    if(P3->IFG & FRSen){

            Stop();
            TurnLeft();
            SpeedUp();

            if((P3->IES & FRSen) == 0)
            {
                TIMER_A0->CCR[1] = 5000;
            }

            P3->IFG &= ~FRSen;
            P3->IES ^= FRSen;

        }


    //Front Left Sensor
    if(P3->IFG & FLSen){

        Stop();
        TurnRight();
        SpeedUp();

        if((P3->IES & FLSen) == 0)
        {
            TIMER_A0->CCR[1] = 5000;
        }

        P3->IFG &= ~FLSen;
        P3->IES ^= FLSen;
    }

    Delay();
    P3->IFG &= ~FRSen;
}

//Back Sensor
void PORT5_IRQHandler(void)
{
    //Back Sensor
    if(P5->IFG & BSen){
        Stop();
        Forward();
        SpeedUp();

        P5->IFG &= ~BSen;
    }
    //Back Right Sensor
    if(P5->IFG & BRSen){

        Stop();
        TurnLeft();
        SpeedUp();

        if((P5->IES & BRSen) == 0)
        {
            TIMER_A0->CCR[1] = 5000;
        }

        P5->IFG &= ~BRSen;
        P5->IES ^= BRSen;
    }

    //Back Left Sensor
    if(P5->IFG & BLSen){

        Stop();
        TurnRight();
        SpeedUp();

        if((P5->IES & FLSen) == 0)
        {
            TIMER_A0->CCR[1] = 5000;
        }

        P5->IFG &= ~BLSen;
        P5->IES ^= BLSen;
}
    Delay();
   // P5->IFG &= ~0xFF;
}

//CONTROL FUNCTIONS
void Stop(void)
{
    Delay();
    D = 0.0f;
    TIMER_A0->CCR[4] = Motor_period*D;
    TIMER_A0->CCR[3] = Motor_period*D;

}
void Backward(void)
{
    Delay();
    P2->OUT &= ~MRFor;
    P2->OUT |= MRBack;

    P6->OUT &= ~MLFor;
    P6->OUT |= MLBack;

    TIMER_A0->CCR[1] = 5000;

    P2->OUT &= ~BIT0;
    P2->OUT |= BIT1;
}

void Forward(void)
{
    Delay();
    P2->OUT |= MRFor;
    P2->OUT &= ~MRBack;

    P6->OUT |= MLFor;
    P6->OUT &= ~MLBack;

    TIMER_A0->CCR[1] = 5000;

    P2->OUT &= ~BIT1;
    P2->OUT |= BIT0;

}
void TurnRight(void)
{
    Delay();
    TIMER_A0->CCR[1] = 6000;
}

void TurnLeft(void)
{
    Delay();
    TIMER_A0->CCR[1] = 3500;
}

void SpeedUp(void)
{
    if (D == 0)
    {
        for(i=0;i < 8;i++)
        {
            D += .1;
            TIMER_A0->CCR[4] = Motor_period*D;
            TIMER_A0->CCR[3] = Motor_period*D;

        }
    }
    else
    {
        D = .9f;
        TIMER_A0->CCR[4] = Motor_period*D;
        TIMER_A0->CCR[3] = Motor_period*D;
    }
}

int Random(void)
{
    Delay();
    Rand += 1;

    if (Rand == 5)
    {
        Rand = 0;
    }
    return Rand;
}

void Delay(void)
{
//    for(i=1;i < DELAY*50; i++);
}
