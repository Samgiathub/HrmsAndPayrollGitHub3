using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpPolicyDocReadDetail
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal PolicyDocId { get; set; }

    public DateTime ReadDatetime { get; set; }

    public byte DocType { get; set; }

    public byte IsMobileRead { get; set; }
}
