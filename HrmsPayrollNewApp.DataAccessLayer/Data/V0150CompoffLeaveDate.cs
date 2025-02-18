using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0150CompoffLeaveDate
{
    public decimal? LeaveTranId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? CompOffCredit { get; set; }

    public decimal? CompOffDebit { get; set; }

    public decimal? CompOffBalance { get; set; }

    public decimal? CompOffUsed { get; set; }

    public decimal LeaveApprovalId { get; set; }

    public decimal? LeaveId { get; set; }

    public int Selected { get; set; }
}
