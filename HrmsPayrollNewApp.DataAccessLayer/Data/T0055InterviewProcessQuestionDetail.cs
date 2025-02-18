using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055InterviewProcessQuestionDetail
{
    public decimal RecPostedQuestionProcessId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ProcessId { get; set; }

    public decimal ProcessQId { get; set; }

    public decimal RecPostId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040HrmsRProcessMaster Process { get; set; } = null!;

    public virtual T0045HrmsRProcessTemplate ProcessQ { get; set; } = null!;

    public virtual T0052HrmsPostedRecruitment RecPost { get; set; } = null!;
}
