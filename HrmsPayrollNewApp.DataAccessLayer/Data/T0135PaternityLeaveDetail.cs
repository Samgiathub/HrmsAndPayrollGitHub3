using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0135PaternityLeaveDetail
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LeaveId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal PaternityBalance { get; set; }

    public decimal ValidityDays { get; set; }

    public string LapsStatus { get; set; } = null!;

    public DateTime SystemDate { get; set; }
}
