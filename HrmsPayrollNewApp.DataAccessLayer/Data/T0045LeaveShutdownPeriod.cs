using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0045LeaveShutdownPeriod
{
    public decimal LeaveId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public decimal NoticePeriod { get; set; }
}
