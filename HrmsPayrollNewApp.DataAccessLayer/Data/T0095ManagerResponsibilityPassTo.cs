using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095ManagerResponsibilityPassTo
{
    public decimal TranId { get; set; }

    public decimal? MangerEmpId { get; set; }

    public decimal? PassToEmpId { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? Type { get; set; }

    public DateTime? Timestamp { get; set; }

    public decimal CmpId { get; set; }

    public byte IsManual { get; set; }
}
