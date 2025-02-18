using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0060SurveyEmployeeResponse
{
    public decimal SurveyEmpId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? SurveyId { get; set; }

    public decimal? SurveyQuestionId { get; set; }

    public string? Answer { get; set; }

    public DateTime? ResponseDate { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0050SurveyMaster? Survey { get; set; }

    public virtual T0052SurveyTemplate? SurveyQuestion { get; set; }
}
