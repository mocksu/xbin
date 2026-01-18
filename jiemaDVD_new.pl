#!/usr/bin/perl -w

# 前些天麻省理工学院的两位学生编写出世界上最短的DVD解码程序，而这个纪录最近被一位名为Charles M Hannum的程序员打破，他所编写的解码程序只有442个字节，而那个七行的Perl解码程序则为472个字节。
# Hannum的C程序被叫作：efdtt，据称它的速度相当快，能够达到21.5MBps，在解码时甚至不需要特别进行I/O优化，这样的速度使得该程序在将数据转换为动态图像时完全不会影响MPEG 2的解码处理。
# 相比两个同样小巧的解码程序，前者支持即时解码与回放，但据说它的输出回放偶尔会不稳定。而Hannum的程序则支持平滑回放。
# 以下是此程序的源码：

# /* efdtt.c Author: Charles M. Hannum <root@ihack.net> */
# /* Usage is: cat title-key scrambled.vob | efdtt >clear.vob */

#define K(i)(x[i]^s[i+84])<<
unsigned char x[5],y,z,s[2048];
main(n)
{
    for(read(0,x,5);read(0,s,n=2048);write(1,s,n))
        if(s[y=s[13]%8+20]/16%4==1)
        {
            int i=K(1)17^256+K(0)8,k=K(2)0,j=K(4)17^K(3)9^k*2-k%8^8,a=0,b=0,c=26;
            for(s[y]-=16;--c;i/=2,j/=2)
                a=a*2^i&1,b=b*2^j&1;
            for(j=127;++j<n;c=z+c>y)
                a^=a>>14,a=a>>8^(y=a^a*8^a<<6)<<9,b=b>>8^(z=b^b/8^b>>4^b>>12)<<17,i=s[j],i="7Wo~'G_\216"[i&7]+2^"cr3sfw6v;
            *k+>/n."[i>>4]*2^i*257/8,s[j]=i^(i&i*2&34)*6^z+c+~y;
        }
}
