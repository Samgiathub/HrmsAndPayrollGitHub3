using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040DocumentMaster
{
    public decimal DocId { get; set; }

    public decimal CmpId { get; set; }

    public string DocName { get; set; } = null!;

    public string DocComments { get; set; } = null!;

    public byte DocRequired { get; set; }

    public decimal DocumentTypeId { get; set; }

    public string DocTypeName { get; set; } = null!;
}
