using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsAppraisalInitiationDetail
{
    public decimal ApprDetailId { get; set; }

    public decimal ApprIntId { get; set; }

    public decimal EmpId { get; set; }

    public int? IsEmpSubmit { get; set; }

    public int? IsSupSubmit { get; set; }

    public int? IsTeamSubmit { get; set; }

    public int IsAccept { get; set; }

    public DateTime? EmpSubmitDate { get; set; }

    public DateTime? SupSubmitDate { get; set; }

    public DateTime? TeamSubmitDate { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public decimal? IncrementId { get; set; }

    public virtual T0090HrmsAppraisalInitiation ApprInt { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0090HrmsEmployeeIntrospection> T0090HrmsEmployeeIntrospections { get; set; } = new List<T0090HrmsEmployeeIntrospection>();

    public virtual ICollection<T0091EmployeeGoalScore> T0091EmployeeGoalScores { get; set; } = new List<T0091EmployeeGoalScore>();
}
