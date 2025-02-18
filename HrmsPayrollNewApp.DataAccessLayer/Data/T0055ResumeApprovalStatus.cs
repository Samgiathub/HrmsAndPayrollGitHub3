using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055ResumeApprovalStatus
{
    public decimal? TranId { get; set; }

    public decimal? ResumeId { get; set; }

    public decimal? ResumeStatus { get; set; }

    public decimal CmpId { get; set; }

    public DateTime? ApprovalDate { get; set; }
}
