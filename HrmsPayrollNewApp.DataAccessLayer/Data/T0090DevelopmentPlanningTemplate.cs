using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090DevelopmentPlanningTemplate
{
    public decimal EmpDptId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public int? DptStatus { get; set; }

    public int? FinYear { get; set; }

    public string? EmpComment { get; set; }

    public string? ManagerComment { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? ModifiedDate { get; set; }

    public DateTime StartDate { get; set; }

    public DateTime Enddate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0095DevelopmentPlanningTemplateDetail> T0095DevelopmentPlanningTemplateDetails { get; set; } = new List<T0095DevelopmentPlanningTemplateDetail>();
}
