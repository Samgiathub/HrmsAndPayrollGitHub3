using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999MacMaster
{
    public int TranId { get; set; }

    public int CmpId { get; set; }

    public byte IsEnable { get; set; }

    public byte DenyMac { get; set; }

    public DateTime LastModified { get; set; }
}
