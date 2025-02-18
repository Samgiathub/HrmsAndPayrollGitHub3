using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpMedicalCheckup
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal MedicalId { get; set; }

    public DateTime ForDate { get; set; }

    public string? Description { get; set; }
}
