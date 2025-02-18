using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0060EmpAssessmentView
{
    public decimal EmpAssessmentViewId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public int SaView { get; set; }

    public int KpaView { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
