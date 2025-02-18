using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsGetAnotherEmployee
{
    public decimal EmpId { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal IncrementId { get; set; }

    public DateTime IncrementEffectiveDate { get; set; }
}
