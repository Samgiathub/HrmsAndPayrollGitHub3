using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055HrmsApprFeedbackQuestion
{
    public decimal QueId { get; set; }

    public string? Question { get; set; }

    public string? QueDescription { get; set; }

    public DateTime? PostedDate { get; set; }

    public decimal ApprId { get; set; }

    public decimal? LoginId { get; set; }

    public int? EmpStatus { get; set; }

    public decimal? CmpId { get; set; }

    public int? IsView { get; set; }

    public virtual T0050HrmsAppraisalSetting Appr { get; set; } = null!;

    public virtual T0011Login? Login { get; set; }

    public virtual ICollection<T0090HrmsEmployeeIntrospection> T0090HrmsEmployeeIntrospections { get; set; } = new List<T0090HrmsEmployeeIntrospection>();
}
