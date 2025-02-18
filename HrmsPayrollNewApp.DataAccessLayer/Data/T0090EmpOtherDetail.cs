using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpOtherDetail
{
    public decimal EmpOtherId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string SalaryAccNo { get; set; } = null!;

    public string PanNo { get; set; } = null!;

    public decimal K11Certifies { get; set; }

    public decimal SalesTraining { get; set; }

    public decimal AccountTraining { get; set; }

    public decimal InductionTraining { get; set; }

    public decimal FcmId { get; set; }

    public decimal CcmId { get; set; }

    public decimal UniformGiven { get; set; }

    public decimal CompurterLitercy { get; set; }

    public string InterviewComments { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
