using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0045LeaveAppNoticeSlab
{
    public long TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LeaveId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal LeavePeriod { get; set; }

    public decimal NoticeDays { get; set; }

    public virtual T0040LeaveMaster Leave { get; set; } = null!;
}
