using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsEmployeeIntrospection
{
    public decimal EmpId { get; set; }

    public int? InspectionStatus { get; set; }

    public int? EmpStatus { get; set; }

    public decimal ApprIntId { get; set; }
}
