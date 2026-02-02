'use client';

import Link from 'next/link';
import { ConnectButton } from '@mysten/dapp-kit';

export function Navbar() {
  return (
    <header className="w-full border-b border-foreground/10 bg-background">
      <div className="mx-auto flex h-14 w-full max-w-5xl items-center justify-between px-4">
        <Link href="/" className="text-sm font-semibold tracking-tight">
          NFT Example
        </Link>

        <div className="flex items-center gap-3">
          <ConnectButton />
        </div>
      </div>
    </header>
  );
}
