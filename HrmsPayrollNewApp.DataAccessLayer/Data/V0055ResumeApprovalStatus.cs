using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0055ResumeApprovalStatus
{
    public decimal? TranId { get; set; }

    public decimal? ResumeId { get; set; }

    public decimal? ResumeStatus { get; set; }

    public decimal CmpId { get; set; }

    public DateTime? ApprovalDate { get; set; }

    public DateTime? ResumePostedDate { get; set; }

    public decimal? RecPostId { get; set; }

    public decimal? BranchId { get; set; }
}
