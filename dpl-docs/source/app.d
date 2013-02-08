module app;

import ddox.main;
import vibe.core.log;

int main(string[] args)
{
	setPlainLogging(true);
	return ddoxMain(args);
}
