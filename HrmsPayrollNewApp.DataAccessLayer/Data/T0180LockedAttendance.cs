using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0180LockedAttendance
{
    public int LockId { get; set; }

    public int CmpId { get; set; }

    public int EmpId { get; set; }

    public byte Month { get; set; }

    public short Year { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public DateTime CutOffDate { get; set; }

    public int LoginId { get; set; }

    public DateTime SystemDate { get; set; }
}
