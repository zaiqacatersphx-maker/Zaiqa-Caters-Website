import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo & Slogan
              Expanded(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Zaiqa Caterers",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: const Color(0xFF2C5F2D),
                        ),
                      ),
                      // const SizedBox(height: 10),
                      // Text(
                      //   "Healthy meals delivered to your door.",
                      //   style: GoogleFonts.dmSans(color: Colors.grey),
                      // ),
                    ],
                  ),
                ),
              ),
              // Links columns
              // if (MediaQuery.of(context).size.width > 600) ...[
              //   _FooterColumn(title: "Company", links: const ["About Us", "Our Team", "Partners", "Careers"]),
              //   _FooterColumn(title: "Support", links: const ["FAQ", "Contact Us", "Shipping", "Returns"]),
              //   _FooterColumn(title: "Legal", links: const ["Terms", "Privacy", "Cookies"]),
              // ],
            ],
          ),
          const SizedBox(height: 40),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            "© 2026 Zaiqa Caterers. All rights reserved.",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            "Powered by Versa",
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// class _FooterColumn extends StatelessWidget {
//   final String title;
//   final List<String> links;

//   const _FooterColumn({required this.title, required this.links});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 40),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: GoogleFonts.dmSans(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 20),
//           ...links.map((link) => Padding(
//                 padding: const EdgeInsets.only(bottom: 10),
//                 child: InkWell(
//                   onTap: () {},
//                   child: Text(
//                     link,
//                     style: GoogleFonts.dmSans(color: Colors.grey[600]),
//                   ),
//                 ),
//               )),
//         ],
//       ),
//     );
//   }
// }
