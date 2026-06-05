import 'package:flutter/material.dart';
import 'legal_document_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Política de Privacidade',
      lastUpdated: '04 de junho de 2026',
      sections: [
        LegalSection(
          title: '1. Introdução',
          paragraphs: [
            'O Plant Care ("nós", "nosso") respeita a sua privacidade e está comprometido em proteger seus dados pessoais. Esta Política de Privacidade descreve como coletamos, usamos, armazenamos e compartilhamos suas informações quando você utiliza nosso aplicativo.',
            'Esta política está em conformidade com a Lei Geral de Proteção de Dados (LGPD - Lei nº 13.709/2018) do Brasil.',
          ],
        ),
        LegalSection(
          title: '2. Dados que Coletamos',
          paragraphs: [
            'Dados de cadastro: nome completo, endereço de email e senha (armazenada de forma criptografada pelo Firebase Authentication).',
            'Dados de autenticação: ao usar o Google Sign-In, recebemos seu nome, email e foto de perfil do Google.',
            'Dados das plantas: nome, tipo, descrição, localização, configurações de cuidado (umidade, temperatura, frequência de rega), datas de plantio e rega.',
            'Conteúdo enviado: fotos das suas plantas e foto de perfil, armazenadas no Firebase Storage.',
            'Dados de uso: registros de rega, histórico de cuidados e alertas gerados pelo aplicativo.',
            'Dados técnicos: token de notificação push (FCM Token) para envio de alertas sobre suas plantas.',
          ],
        ),
        LegalSection(
          title: '3. Como Usamos seus Dados',
          paragraphs: [
            'Fornecer e manter as funcionalidades do aplicativo (cadastro de plantas, lembretes, histórico).',
            'Autenticar seu acesso e proteger sua conta.',
            'Enviar notificações push sobre rega, alertas de saúde e outras informações relevantes para suas plantas.',
            'Melhorar o aplicativo por meio de análises agregadas e anônimas de uso.',
            'Cumprir obrigações legais e responder solicitações de autoridades competentes.',
          ],
        ),
        LegalSection(
          title: '4. Base Legal para Tratamento (LGPD)',
          paragraphs: [
            'Os dados são tratados com base no seu consentimento (ao aceitar esta política) e na execução do contrato de prestação do serviço de monitoramento de plantas. Para dados sensíveis ou de crianças, exigimos consentimento explícito dos pais ou responsáveis.',
          ],
        ),
        LegalSection(
          title: '5. Compartilhamento de Dados',
          paragraphs: [
            'Não vendemos nem alugamos seus dados pessoais. Compartilhamos informações apenas com prestadores de serviços essenciais:',
            '• Google Firebase: Authentication, Firestore, Storage, Cloud Messaging - para autenticação, armazenamento e notificações.',
            '• Google Sign-In: para login social com sua conta Google.',
            'Esses prestadores possuem suas próprias políticas de privacidade e padrões de segurança.',
            'Podemos divulgar dados se exigido por lei, ordem judicial ou para proteger nossos direitos legais.',
          ],
        ),
        LegalSection(
          title: '6. Armazenamento e Segurança',
          paragraphs: [
            'Seus dados são armazenados em servidores seguros do Google Firebase, com criptografia em trânsito (HTTPS/TLS) e em repouso. Senhas são armazenadas com hash pelo Firebase Authentication (não temos acesso à senha em texto puro).',
            'As regras de segurança do Firestore garantem que apenas você acesse seus próprios dados.',
            'Apesar de todos os esforços, nenhum sistema é 100% seguro. Em caso de incidente de segurança, notificaremos os usuários afetados conforme exigido pela LGPD.',
          ],
        ),
        LegalSection(
          title: '7. Retenção de Dados',
          paragraphs: [
            'Mantemos seus dados enquanto sua conta estiver ativa. Ao excluir a conta, todos os dados pessoais, plantas, fotos e histórico são removidos permanentemente dos nossos servidores em até 90 dias.',
            'Dados podem ser retidos por prazo maior se necessário para cumprimento de obrigação legal.',
          ],
        ),
        LegalSection(
          title: '8. Seus Direitos (LGPD)',
          paragraphs: [
            'Você tem direito a:',
            '• Confirmação da existência de tratamento dos seus dados.',
            '• Acesso aos seus dados (exportação).',
            '• Correção de dados incompletos ou desatualizados.',
            '• Anonimização, bloqueio ou eliminação de dados desnecessários.',
            '• Portabilidade dos dados.',
            '• Revogação do consentimento.',
            'Para exercer esses direitos, acesse as configurações do aplicativo ou entre em contato pelo email: privacidade@plantcare.app',
          ],
        ),
        LegalSection(
          title: '9. Cookies e Tecnologias Semelhantes',
          paragraphs: [
            'O aplicativo não utiliza cookies. Versão web pode utilizar armazenamento local (localStorage) para manter sua sessão ativa e preferências.',
          ],
        ),
        LegalSection(
          title: '10. Menores de Idade',
          paragraphs: [
            'O aplicativo pode ser utilizado por menores de 18 anos, desde que com consentimento dos pais ou responsáveis. Não coletamos intencionalmente dados de menores sem essa autorização. Pais podem solicitar a exclusão da conta do menor a qualquer momento.',
          ],
        ),
        LegalSection(
          title: '11. Alterações nesta Política',
          paragraphs: [
            'Podemos atualizar esta Política de Privacidade periodicamente. Notificaremos sobre alterações significativas. A data da última atualização está indicada no topo deste documento.',
          ],
        ),
        LegalSection(
          title: '12. Encarregado de Proteção de Dados (DPO)',
          paragraphs: [
            'Para questões sobre privacidade e proteção de dados, entre em contato com nosso DPO pelo email: dpo@plantcare.app',
          ],
        ),
      ],
    );
  }
}
