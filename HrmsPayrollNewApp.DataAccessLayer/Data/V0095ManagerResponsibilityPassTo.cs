using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0095ManagerResponsibilityPassTo
{
    public decimal TranId { get; set; }

    public string? Employee { get; set; }

    public string? EmployeePass { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public decimal CmpId { get; set; }

    public string? Type { get; set; }

    public byte IsManual { get; set; }

    public decimal? MangerEmpId { get; set; }

    public decimal? PassToEmpId { get; set; }
}
