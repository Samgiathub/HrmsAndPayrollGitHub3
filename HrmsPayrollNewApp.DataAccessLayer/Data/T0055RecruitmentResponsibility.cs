using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055RecruitmentResponsibility
{
    public decimal RecRespId { get; set; }

    public decimal CmpId { get; set; }

    public decimal RecReqId { get; set; }

    public string? Responsibility { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0050HrmsRecruitmentRequest RecReq { get; set; } = null!;
}
