using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpKpiApproval
{
    public decimal TranId { get; set; }

    public decimal? EmpKpiId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime? ApprovalDate { get; set; }

    public string? ApprovalComments { get; set; }

    public decimal? LoginId { get; set; }

    public int? RptLevel { get; set; }

    public int? ApprovalStatus { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0080EmpKpi? EmpKpi { get; set; }

    public virtual ICollection<T0090SubKpiMasterLevel> T0090SubKpiMasterLevels { get; set; } = new List<T0090SubKpiMasterLevel>();

    public virtual ICollection<T0100EmpKpiMasterLevel> T0100EmpKpiMasterLevels { get; set; } = new List<T0100EmpKpiMasterLevel>();

    public virtual ICollection<T0100KpiobjectivesLevel> T0100KpiobjectivesLevels { get; set; } = new List<T0100KpiobjectivesLevel>();
}
