$src = '
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Text;

public static class Native {
	[DllImport("advapi32.dll", EntryPoint = "CredReadW", CharSet = CharSet.Unicode, SetLastError = true)]
	static extern bool CredRead(string target, int type, int reservedFlag, out IntPtr credentialPtr);

	[DllImport("Advapi32.dll", SetLastError = true, EntryPoint = "CredWriteW", CharSet = CharSet.Unicode)]
	static extern bool CredWrite(ref CREDENTIAL userCredential, UInt32 flags);

	[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
	struct CREDENTIAL {
		public int flags;
		public int type;
		[MarshalAs(UnmanagedType.LPWStr)]
		public string targetName;
		[MarshalAs(UnmanagedType.LPWStr)]
		public string comment;
		public System.Runtime.InteropServices.ComTypes.FILETIME lastWritten;
		public int credentialBlobSize;
		public IntPtr credentialBlob;
		public int persist;
		public int attributeCount;
		public IntPtr credAttribute;
		[MarshalAs(UnmanagedType.LPWStr)]
		public string targetAlias;
		[MarshalAs(UnmanagedType.LPWStr)]
		public string userName;
	}

	public static string[] Creds(string target) {
		IntPtr credPtr = IntPtr.Zero;
		var ok = Native.CredRead(target, 1, 0, out credPtr);
		if(!ok) return null;

		// Decode the credential
		var cred = (Native.CREDENTIAL)Marshal.PtrToStructure(credPtr, typeof(Native.CREDENTIAL));
		return new string[] { cred.userName, Marshal.PtrToStringAuto(cred.credentialBlob) };
	}

	public static void Creds(string target, string username, string password) {
		var cred = new Native.CREDENTIAL() {
			type = 0x01, // Generic
			targetName = target,
			credentialBlob = Marshal.StringToCoTaskMemUni(password),
			persist = 0x02, // Local machine
			attributeCount = 0,
			userName = username
		};
		cred.credentialBlobSize = Encoding.Unicode.GetByteCount(password);
		if(!Native.CredWrite(ref cred, 0)) {
			throw new Win32Exception(Marshal.GetLastWin32Error());
		}
	}
}
';

if(!('native' -as [type])) {
	add-type $src
}

function get_creds($target) {
	return [native]::creds($target)
}

function set_creds($target, $username, $password) {
	[native]::creds($target, $username, $password)
}

# convert secure string back to string
# from http://blogs.msdn.com/b/fpintos/archive/2009/06/12/how-to-properly-convert-securestring-to-string.aspx
function unsecure($secure) {
	$ptr = [intptr]::zero
	$marshal = [runtime.interopservices.marshal]
	try {
		$ptr = $marshal::SecureStringToGlobalAllocUnicode($secure)
		return $marshal::PtrToStringUni($ptr)
	} finally {
		$marshal::ZeroFreeGlobalAllocUnicode($ptr)
	}
}

function check_creds($url, $username, $password) {
	$res, $status = geturl $url $username $password
	return $status -eq 200
}

function ensure_creds($url) {
	$saved = get_creds (host $url)
	if($saved -and (check_creds $url @saved)) { return $saved }

	$username = read-host 'username'

	$max_attempts = 3
	for($i = 0; $i -lt $max_attempts; $i++) {
		$password = unsecure (read-host "password for $username" -assecurestring)
		
		if($status -eq 200) { break }
		write-host "invalid password"
		if($i -eq $max_attempts - 1) {
			abort "aborting after $max_attempts failed password attempts"
		}
	}

	set_creds (host $url) $username $password
	$username, $password
}