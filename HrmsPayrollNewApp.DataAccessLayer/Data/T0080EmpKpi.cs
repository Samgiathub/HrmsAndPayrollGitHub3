using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080EmpKpi
{
    public decimal EmpKpiId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public int? Status { get; set; }

    public DateTime CreatedDate { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? LastEditDate { get; set; }

    public int? FinancialYr { get; set; }

    public string? EmpComments { get; set; }

    public string? MgrComments { get; set; }

    public string? HrComments { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0040EmpKpiMaster> T0040EmpKpiMasters { get; set; } = new List<T0040EmpKpiMaster>();

    public virtual ICollection<T0080Kpiobjective> T0080Kpiobjectives { get; set; } = new List<T0080Kpiobjective>();

    public virtual ICollection<T0080SubKpiMaster> T0080SubKpiMasters { get; set; } = new List<T0080SubKpiMaster>();

    public virtual ICollection<T0090EmpKpiApproval> T0090EmpKpiApprovals { get; set; } = new List<T0090EmpKpiApproval>();
}
